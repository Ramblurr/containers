#!/bin/sh -eu

if [ "--help" = "$1" ]; then
    echo [COMMAND] [FLAGS]
    echo The container can be run with different roles by specifying a command
    echo
    echo Available commands:
    echo app      - Run as web application
    echo worker   - Run as queue worker
    echo scheduler - Run as task scheduler
    echo
    echo If no command is provided, the arguments are executed directly
    echo
    echo Examples:
    echo docker run ramblurr/invoiceninja-octane:5 app
    echo docker run ramblurr/invoiceninja-octane:5 app --port=8080 --workers=2
    echo docker run ramblurr/invoiceninja-octane:5 frankenphp php-cli artisan help
    echo docker run ramblurr/invoiceninja-octane:5 worker --verbose --sleep=3 --tries=3 --max-time=3600
    echo docker run ramblurr/invoiceninja-octane:5 scheduler
    echo
    exit 0
fi

case "$1" in
    app)
        shift
        export LARAVEL_ROLE="app"
        cmd="frankenphp php-cli artisan octane:frankenphp"

        if [ "$APP_ENV" = "production" ]; then
            frankenphp php-cli artisan optimize
        fi

        frankenphp php-cli artisan package:discover

        # Run migrations (if any)
        frankenphp php-cli artisan migrate --force

        # If first IN run, it needs to be initialized
        if [ "$(frankenphp php-cli artisan tinker --execute='echo Schema::hasTable("accounts") && !App\Models\Account::all()->first();')" = "1" ]; then
            echo "Running initialization..."

            frankenphp php-cli artisan db:seed --force

            if [ -n "${IN_USER_EMAIL}" ] && [ -n "${IN_PASSWORD}" ]; then
                frankenphp php-cli artisan ninja:create-account --email "${IN_USER_EMAIL}" --password "${IN_PASSWORD}"
            else
                echo "Initialization failed - Set IN_USER_EMAIL and IN_PASSWORD in .env"
                exit 1
            fi
        fi

        if [ $# -gt 0 ]; then
            exec $cmd "$@"
        else
            exec $cmd
        fi
        ;;

    worker)
        shift
        export LARAVEL_ROLE="worker"
        cmd="frankenphp php-cli artisan queue:work"

        if [ $# -gt 0 ]; then
            exec $cmd "$@"
        else
            exec $cmd
        fi
        ;;

    scheduler)
        shift
        export LARAVEL_ROLE="scheduler"
        cmd="frankenphp php-cli artisan schedule:work"

        if [ $# -gt 0 ]; then
            exec $cmd "$@"
        else
            exec $cmd
        fi
        ;;

    *)
        # Default case: execute the command as is
        exec "$@"
        ;;
esac
