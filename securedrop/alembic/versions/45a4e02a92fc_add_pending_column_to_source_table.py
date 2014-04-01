"""add pending column to source table

Revision ID: 45a4e02a92fc
Revises: None
Create Date: 2014-03-31 23:55:58.660501

"""

# revision identifiers, used by Alembic.
revision = '45a4e02a92fc'
down_revision = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('sources', sa.Column('pending', sa.Boolean, default=True))


def downgrade():
    op.drop_column('sources', 'pending')
