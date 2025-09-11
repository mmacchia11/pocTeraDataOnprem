# pocTeraDataOnprem

Simulación de Data Warehouse (ClickHouse) on-premise usando Docker para pruebas e integraciones con AWS.

## Descripción

Este repositorio proporciona un contenedor Docker que simula un Data Warehouse ClickHouse on-premise, diseñado para:

- Pruebas de integraciones con servicios AWS (Glue, DMS, Redshift, Athena)
- Desarrollo de pipelines de datos analíticos
- Simulación de Data Warehouse columnar on-premise
- Testing de queries OLAP y conectividad

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
- **Puerto HTTP**: 1025
- **Puerto TCP**: 1026
- **Usuario Admin**: `admin` / `root` (fijas)
- **Usuario App**: `app_user` (password generado automáticamente)
- **Base de datos**: sample_dw

> ⚠️ **Importante**: Las credenciales se generan automáticamente al iniciar el contenedor. Ver [CREDENTIALS.md](CREDENTIALS.md) para detalles completos.

### Acceso a Credenciales

```bash
# Ejecutar con volumen para credenciales
docker run -d --name teradata-onprem \
  -p 1025:1025 -p 1026:1026 \
  -v $(pwd)/credentials:/tmp/credentials \
  ghcr.io/tu-usuario/poc-teradata-onprem:latest

# Leer credenciales generadas
cat credentials/clickhouse_credentials.txt
```

### Usando Python

```python
from src.teradata_onprem.connection import execute_query

# Cargar credenciales dinámicas
def load_credentials():
    creds = {}
    with open('./credentials/clickhouse_credentials.txt', 'r') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                creds[key] = value
    return creds

creds = load_credentials()

# Ejecutar queries analíticas en ClickHouse
result = execute_query(
    "SELECT customer_key, customer_name FROM dim_customers WHERE is_current = 1 LIMIT 10",
    user=creds['APP_USER'],
    password=creds['APP_PASS']
)
print(result['data'])

# Query analítica de ejemplo
sales_query = """
SELECT 
    toYYYYMM(sale_date) as month,
    sum(net_amount) as total_sales,
    count(DISTINCT customer_key) as customers
FROM fact_sales 
WHERE sale_date >= '2024-01-01'
GROUP BY month
ORDER BY month
"""
result = execute_query(sales_query, user=creds['APP_USER'], password=creds['APP_PASS'])
print(result['data'])
```

### Usando cliente CLI

```bash
# Instalar cliente ClickHouse
pip install clickhouse-connect

# Conectar desde línea de comandos
clickhouse-client --host localhost --port 1026 --user app_user --password <generated_pass>

# Test de conectividad
python -c "from src.teradata_onprem.connection import test_connection; print('Connected:', test_connection())"

# Query de ejemplo
clickhouse-client --host localhost --port 1026 --query "SELECT count() FROM dim_customers"
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
