FROM ghost:latest

# Script que injeta a config de email antes do Ghost iniciar
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
