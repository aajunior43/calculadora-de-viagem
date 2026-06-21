FROM php:8.3-apache

COPY apps/favoritos/ /var/www/html/
COPY services/favoritos/entrypoint.sh /usr/local/bin/favoritos-entrypoint

RUN rm -f /var/www/html/index.php \
    && chmod +x /usr/local/bin/favoritos-entrypoint

ENTRYPOINT ["favoritos-entrypoint"]
CMD ["apache2-foreground"]

