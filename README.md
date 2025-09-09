# pocTeraDataOnprem

Simulación de Teradata on-premise usando Docker para pruebas e integraciones con AWS.

## Descripción

Este repositorio proporciona un contenedor Docker que simula un entorno Teradata on-premise, diseñado para:

- Pruebas de integraciones con servicios AWS (Glue, DMS, Redshift, Athena)
- Desarrollo de pipelines de datos
- Simulación de Data Warehouse on-premise
- Testing de conectividad y queries

## Estructura del Proyecto

```
pocTeraDataOnprem/
├── src/teradata_onprem/     # Utilidades de conexión
├── docker/init-scripts/     # Scripts SQL de inicialización
├── tests/                   # Tests del contenedor
├── .github/workflows/       # CI/CD pipeline
├── Dockerfile              # Imagen Teradata
├── Makefile               # Comandos de build y calidad
└── pyproject.toml         # Configuración PDM
```

## Uso Rápido

### Usando la imagen publicada

```bash
# Descargar y ejecutar desde GHCR
docker run -d --name teradata-onprem \
  -p 1025:1025 -p 1026:1026 \
  ghcr.io/tu-usuario/poc-teradata-onprem:latest
```

### Construir localmente

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/pocTeraDataOnprem.git
cd pocTeraDataOnprem

# Construir imagen
make build

# Ejecutar contenedor
make run
```

## Conexión a Teradata

### Credenciales Dinámicas
- **Host**: localhost
- **Puerto**: 1025
- **Usuario Root**: `root` (password generado automáticamente)
- **Usuario App**: `app_user` (password generado automáticamente)
- **Base de datos**: sample_db

> ⚠️ **Importante**: Las credenciales se generan automáticamente al iniciar el contenedor. Ver [CREDENTIALS.md](CREDENTIALS.md) para detalles completos.

### Acceso a Credenciales

```bash
# Ejecutar con volumen para credenciales
docker run -d --name teradata-onprem \
  -p 1025:1025 -p 1026:1026 \
  -v $(pwd)/credentials:/tmp/credentials \
  ghcr.io/tu-usuario/poc-teradata-onprem:latest

# Leer credenciales generadas
cat credentials/teradata_credentials.txt
```

### Usando Python

```python
from src.teradata_onprem.connection import get_connection

# Cargar credenciales dinámicas
def load_credentials():
    creds = {}
    with open('./credentials/teradata_credentials.txt', 'r') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                creds[key] = value
    return creds

creds = load_credentials()

# Conectar con credenciales dinámicas
with get_connection(
    user=creds['APP_USER'], 
    password=creds['APP_PASS']
) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM sample_db.customers LIMIT 10")
        results = cur.fetchall()
        print(results)
```

### Usando cliente CLI

```bash
# Instalar cliente Teradata
pip install teradatasql

# Conectar desde línea de comandos
python -c "from src.teradata_onprem.connection import test_connection; print('Connected:', test_connection())"
```

## Montaje de Datasets

Este repositorio es un skeleton limpio. Para montar datasets desde otros repositorios:

```bash
# Montar scripts SQL adicionales
docker run -d --name teradata-onprem \
  -p 1025:1025 -p 1026:1026 \
  -v /path/to/your/data:/docker-entrypoint-initdb.d \
  ghcr.io/tu-usuario/poc-teradata-onprem:latest

# Montar archivos CSV para carga
docker run -d --name teradata-onprem \
  -p 1025:1025 -p 1026:1026 \
  -v /path/to/csv/files:/data \
  ghcr.io/tu-usuario/poc-teradata-onprem:latest
```

## Desarrollo

### Requisitos
- Python 3.11+
- PDM
- Docker

### Setup

```bash
# Instalar dependencias
make install

# Ejecutar quality checks
make quality

# Ejecutar tests
make test
```

### Comandos disponibles

```bash
make help          # Mostrar ayuda
make install       # Instalar dependencias
make quality       # Ejecutar linters y type checking
make test          # Ejecutar tests
make build         # Construir imagen Docker
make push          # Subir imagen a registry
make run           # Ejecutar contenedor localmente
make stop          # Parar y remover contenedor
make clean         # Limpiar archivos temporales
```

## CI/CD Pipeline

El pipeline de GitHub Actions ejecuta:

### En cada PR
- Quality checks (Ruff, Pylint, Mypy)
- Tests unitarios
- Coverage report

### En merge a main o tags v*
- Quality checks
- Build de imagen Docker
- Push a GitHub Container Registry (GHCR)

### Tags de imagen
- `latest` - última versión de main
- `main-<sha>` - commit específico de main
- `v<version>` - releases con tags

## Estructura de Base de Datos

El contenedor incluye una estructura básica:

```sql
-- Base de datos: sample_db
-- Usuario: sample_user / sample_user

-- Tablas de ejemplo (vacías)
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    created_date DATE
) PRIMARY INDEX (customer_id);

CREATE TABLE orders (
    order_id INTEGER NOT NULL,
    customer_id INTEGER,
    order_date DATE,
    total_amount DECIMAL(10,2)
) PRIMARY INDEX (order_id);
```

## Integración con AWS

Este contenedor está diseñado para integrarse con:

- **AWS Glue**: Como fuente de datos para ETL jobs
- **AWS DMS**: Para migración de datos a RDS/Redshift
- **Amazon Redshift**: Como origen para data warehousing
- **Amazon Athena**: Para queries federadas

## Troubleshooting

### Contenedor no inicia
```bash
# Verificar logs
docker logs teradata-onprem

# Verificar puertos
netstat -an | grep 1025
```

### Problemas de conexión
```bash
# Test de conectividad
python -c "from src.teradata_onprem.connection import test_connection; print(test_connection())"

# Verificar que el contenedor esté corriendo
docker ps | grep teradata
```

## Licencia

MIT License
