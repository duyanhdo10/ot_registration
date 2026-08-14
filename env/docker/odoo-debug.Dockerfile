FROM odoo:17.0

USER root

RUN python3 -m pip install \
    --no-cache-dir \
    "debugpy>=1.8,<2"

USER odoo
