#!/bin/bash
set -e  # stop on error

echo "--------------------------------------------------"
echo "Stopping Docker Compose and removing volumes..."
docker compose down -v

echo "Stopping any running React processes..."
# Trova e uccide tutti i processi npm run dev
pkill -f "npm run dev" || true

echo "--------------------------------------------------"
echo "Starting build process..."

# Cicla su tutte le cartelle nella directory corrente
for dir in */; do
    echo "--------------------------------------------------"
    echo "Processing directory: $dir"

    # Controlla se è un progetto Quarkus (presenza di pom.xml e src/main/docker)
    if [[ -f "$dir/pom.xml" && -f "$dir/src/main/docker/Dockerfile.jvm" ]]; then
        echo "Detected Quarkus project: $dir"
        (
            cd "$dir"
            echo "Running: mvn clean install -DskipTests"
            mvn clean install -DskipTests

            echo "Building Docker image: ${dir%/}"
            docker build -f src/main/docker/Dockerfile.jvm -t "${dir%/}" .
        )
    
    # Controlla se è un progetto React (presenza di package.json)
    elif [[ -f "$dir/package.json" ]]; then
        echo "Detected React project: $dir"
        (
            cd "$dir"
            echo "Running: npm install"
            npm install

            echo "Running: npm run dev in background"
            npm run dev &
        )
    
    else
        echo "Skipping $dir: Not recognized as Quarkus or React project"
    fi
done

echo "--------------------------------------------------"
echo "Starting Docker Compose..."
docker compose up --build


# #!/bin/bash
# MICROSERVIZI=(
#   progetti-neo-bank-gateway
#   progetti-neo-bank-ext-system
#   progetti-neo-bank-conto-corrente
#   progetti-neo-bank-cliente
#   progetti-neo-bank-carta
#   progetti-neo-bank-frontend
#   progetti-neo-bank-auth
# )

# for svc in "${MICROSERVIZI[@]}"; do
#   docker tag $svc paolovezzoso91/$svc:latest
#   docker push paolovezzoso91/$svc:latest
# done

