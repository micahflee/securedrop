# -*- coding: utf-8 -*-

from flask import (Blueprint, render_template, request, url_for, redirect,
                   current_app, flash)
from flask_babel import gettext
from sqlalchemy.exc import IntegrityError

from db import (db_session, Journalist, InvalidUsernameException,
                PasswordError)
from journalist_app.decorators import admin_required
from journalist_app.utils import make_password


def make_blueprint(config):
    view = Blueprint('admin', __name__)

    @view.route('/', methods=('GET', 'POST'))
    @admin_required
    def index():
        users = Journalist.query.all()
        return render_template("admin.html", users=users)

    @view.route('/add', methods=('GET', 'POST'))
    @admin_required
    def add_user():
        if request.method == 'POST':
            form_valid = True
            username = request.form['username']

            password = request.form['password']
            is_admin = bool(request.form.get('is_admin'))

            if form_valid:
                try:
                    otp_secret = None
                    if request.form.get('is_hotp', False):
                        otp_secret = request.form.get('otp_secret', '')
                    new_user = Journalist(username=username,
                                          password=password,
                                          is_admin=is_admin,
                                          otp_secret=otp_secret)
                    db_session.add(new_user)
                    db_session.commit()
                except PasswordError:
                    flash(gettext(
                        'There was an error with the autogenerated password. '
                        'User not created. Please try again.'), 'error')
                    form_valid = False
                except InvalidUsernameException as e:
                    form_valid = False
                    flash('Invalid username: ' + str(e), "error")
                except IntegrityError as e:
                    db_session.rollback()
                    form_valid = False
                    if ("UNIQUE constraint failed: journalists.username"
                            in str(e)):
                        flash(gettext("That username is already in use"),
                              "error")
                    else:
                        flash(gettext("An error occurred saving this user"
                                      " to the database."
                                      " Please inform your administrator."),
                              "error")
                        current_app.logger.error("Adding user '{}' failed: {}"
                                                 .format(username, e))

            if form_valid:
                return redirect(url_for('admin.new_user_two_factor',
                                        uid=new_user.id))

        return render_template("admin_add_user.html", password=make_password())

    @view.route('/2fa', methods=('GET', 'POST'))
    @admin_required
    def new_user_two_factor():
        user = Journalist.query.get(request.args['uid'])

        if request.method == 'POST':
            token = request.form['token']
            if user.verify_token(token):
                flash(gettext(
                    "Token in two-factor authentication "
                    "accepted for user {user}.").format(
                        user=user.username),
                    "notification")
                return redirect(url_for("admin.index"))
            else:
                flash(gettext(
                    "Could not verify token in two-factor authentication."),
                      "error")

        return render_template("admin_new_user_two_factor.html", user=user)

    @view.route('/reset-2fa-totp', methods=['POST'])
    @admin_required
    def reset_two_factor_totp():
        uid = request.form['uid']
        user = Journalist.query.get(uid)
        user.is_totp = True
        user.regenerate_totp_shared_secret()
        db_session.commit()
        return redirect(url_for('admin.new_user_two_factor', uid=uid))

    return view
