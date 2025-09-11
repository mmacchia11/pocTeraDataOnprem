# Gestión de Credenciales - Teradata On-Premise

## Generación Automática de Credenciales

Este contenedor genera automáticamente credenciales únicas cada vez que se inicia, proporcionando mayor seguridad para integraciones.

## Credenciales Generadas

Al iniciar el contenedor, se crean automáticamente:

### Usuario Root (Administrador)
- **Usuario**: `root`
- **Password**: Generado aleatoriamente (12 caracteres)
- **Permisos**: Acceso completo a todas las bases de datos

### Usuario Aplicación
- **Usuario**: `app_user` 
- **Password**: Generado aleatoriamente (12 caracteres)
- **Permisos**: SELECT, INSERT, UPDATE, DELETE en `sample_db`

### Base de Datos
- **Nombre**: `sample_db`
- **Host**: `localhost`
- **Puerto**: `1025`

## Acceso a las Credenciales

### Opción 1: Archivo de credenciales (Recomendado)

```bash
# Ejecutar contenedor con volumen para credenciales
docker run -d --name teradata-onprem \
  -p 1025:1025 -p 1026:1026 \
  -v $(pwd)/credentials:/tmp/credentials \
  ghcr.io/tu-org/poc-teradata-onprem:latest

# Leer credenciales generadas
cat credentials/teradata_credentials.txt
```

### Opción 2: Logs del contenedor

```bash
# Ver credenciales en los logs
docker logs teradata-onprem | grep -A 10 "Credentials generated"
```

### Opción 3: Ejecutar comando dentro del contenedor

```bash
# Acceder al archivo de credenciales
docker exec teradata-onprem cat /tmp/teradata_credentials.txt
```

## Uso desde Otros Repositorios

### Docker Compose (Recomendado)

```yaml
version: '3.8'
services:
  teradata:
    image: ghcr.io/tu-org/poc-teradata-onprem:latest
    ports:
      - "1025:1025"
      - "1026:1026"
    volumes:
      - ./credentials:/tmp/credentials
      - ./data:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD", "cat", "/tmp/teradata_credentials.txt"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Script de Inicialización

```bash
#!/bin/bash
# start-teradata.sh

# Iniciar contenedor
docker run -d --name teradata-onprem \
  -p 1025:1025 -p 1026:1026 \
  -v $(pwd)/credentials:/tmp/credentials \
  ghcr.io/tu-org/poc-teradata-onprem:latest

# Esperar a que se generen las credenciales
echo "Esperando generación de credenciales..."
sleep 30

# Leer y mostrar credenciales
if [ -f "./credentials/teradata_credentials.txt" ]; then
    echo "=== CREDENCIALES TERADATA ==="
    cat ./credentials/teradata_credentials.txt
    echo "============================"
else
    echo "Error: No se pudieron obtener las credenciales"
    exit 1
fi
```

## Conexión con Credenciales Dinámicas

### Python

```python
import os
from src.teradata_onprem.connection import get_connection

def load_credentials(file_path="./credentials/teradata_credentials.txt"):
    """Cargar credenciales desde archivo."""
    creds = {}
    with open(file_path, 'r') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                creds[key] = value
    return creds

# Cargar credenciales
creds = load_credentials()

# Conectar usando credenciales dinámicas
with get_connection(
    host=creds['HOST'],
    user=creds['APP_USER'],
    password=creds['APP_PASS']
) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM sample_db.customers LIMIT 10")
        results = cur.fetchall()
        print(results)
```

### Bash

```bash
#!/bin/bash
# Cargar credenciales
source ./credentials/teradata_credentials.txt

# Usar en scripts
echo "Conectando como: $APP_USER"
python -c "
from src.teradata_onprem.connection import get_connection
conn = get_connection(user='$APP_USER', password='$APP_PASS')
print('Conexión exitosa!')
"
```

## Integración con CI/CD

### GitHub Actions

```yaml
- name: Start Teradata Container
  run: |
    docker run -d --name teradata-onprem \
      -p 1025:1025 -p 1026:1026 \
      -v ${{ github.workspace }}/credentials:/tmp/credentials \
      ghcr.io/tu-org/poc-teradata-onprem:latest
    
    # Esperar credenciales
    sleep 30
    
    # Exportar como variables de entorno
    source ./credentials/teradata_credentials.txt
    echo "TERADATA_USER=$APP_USER" >> $GITHUB_ENV
    echo "TERADATA_PASS=$APP_PASS" >> $GITHUB_ENV
```

## Seguridad

### Buenas Prácticas

1. **Nunca hardcodear credenciales** en código fuente
2. **Usar volúmenes** para acceder a credenciales
3. **Rotar credenciales** reiniciando el contenedor
4. **Limitar permisos** del usuario aplicación
5. **Monitorear accesos** mediante logs

### Rotación de Credenciales

```bash
# Rotar credenciales (reiniciar contenedor)
docker stop teradata-onprem
docker rm teradata-onprem
rm -rf ./credentials/*

# Iniciar con nuevas credenciales
docker run -d --name teradata-onprem \
  -p 1025:1025 -p 1026:1026 \
  -v $(pwd)/credentials:/tmp/credentials \
  ghcr.io/tu-org/poc-teradata-onprem:latest
```

## Troubleshooting

### Credenciales no se generan

```bash
# Verificar logs de inicialización
docker logs teradata-onprem

# Verificar permisos del volumen
ls -la ./credentials/

# Verificar que el script sea ejecutable
docker exec teradata-onprem ls -la /docker-entrypoint-initdb.d/
```

### Conexión rechazada

```bash
# Verificar que las credenciales sean correctas
cat ./credentials/teradata_credentials.txt

# Test de conectividad
docker exec teradata-onprem /opt/teradata/tdat/bin/tdsqlc -h localhost -u $APP_USER -p $APP_PASS
```