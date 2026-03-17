docker compose -f ./development.compose.yaml --env-file .env.development pull
docker compose -f ./development.compose.yaml --env-file .env.development down --remove-orphans
docker compose -f ./development.compose.yaml --env-file .env.development up -d
PAUSE
