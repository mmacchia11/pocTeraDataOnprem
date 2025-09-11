# Prompt para Crear Repositorio de Dataset

## Contexto

Necesito crear un repositorio que use imágenes Docker pre-construidas para simular entornos on-premise. Este repositorio debe:

1. **Usar imágenes existentes** desde GitHub Container Registry (GHCR)
2. **Montar datasets** (SQL, CSV, JSON) en las imágenes
3. **Configurar docker-compose** para levantar el entorno completo
4. **Incluir scripts** de inicialización y carga de datos
5. **Documentar** cómo usar el entorno para pruebas/demos

## Imágenes Disponibles

### Imagen 1: Teradata On-Premise (Base de Datos)
- **Imagen**: `ghcr.io/theboys2025jmss-creator/poc-teradata-onprem:latest`
- **Puerto**: 1025
- **Credenciales**:
  - Admin: `admin_user` / `root` (fijas)
  - App: `app_user` / `app_pass` (generado dinámicamente)
- **Base de datos**: sample_db
- **Volúmenes**:
  - `/docker-entrypoint-initdb.d/` - Scripts SQL de inicialización
  - `/tmp/credentials/` - Archivo de credenciales generadas
  - `/data/` - Archivos CSV/JSON para carga

#### Esquema de Base de Datos Disponible (Completo):
```sql
-- Entidades principales
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    customer_type VARCHAR(20),
    credit_limit DECIMAL(12,2),
    created_date DATE,
    last_updated TIMESTAMP
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INTEGER,
    supplier_id INTEGER,
    unit_price DECIMAL(10,2),
    units_in_stock INTEGER,
    units_on_order INTEGER,
    reorder_level INTEGER,
    discontinued CHAR(1),
    created_date DATE
);

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(50),
    description VARCHAR(200)
);

CREATE TABLE suppliers (
    supplier_id INTEGER PRIMARY KEY,
    supplier_name VARCHAR(100),
    contact_name VARCHAR(50),
    contact_title VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(50),
    region VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    employee_id INTEGER,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    ship_via INTEGER,
    freight DECIMAL(10,2),
    ship_name VARCHAR(100),
    ship_address VARCHAR(200),
    ship_city VARCHAR(50),
    ship_region VARCHAR(50),
    ship_postal_code VARCHAR(20),
    ship_country VARCHAR(50),
    order_status VARCHAR(20),
    total_amount DECIMAL(12,2)
);

CREATE TABLE order_details (
    order_id INTEGER,
    product_id INTEGER,
    unit_price DECIMAL(10,2),
    quantity INTEGER,
    discount DECIMAL(4,2),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(50),
    title_of_courtesy VARCHAR(10),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(200),
    city VARCHAR(50),
    region VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    home_phone VARCHAR(20),
    extension VARCHAR(10),
    reports_to INTEGER,
    salary DECIMAL(10,2),
    department_id INTEGER
);

CREATE TABLE departments (
    department_id INTEGER PRIMARY KEY,
    department_name VARCHAR(50),
    manager_id INTEGER,
    budget DECIMAL(12,2),
    location VARCHAR(100)
);

CREATE TABLE shippers (
    shipper_id INTEGER PRIMARY KEY,
    company_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE sales_summary (
    summary_id INTEGER PRIMARY KEY,
    year_month INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    category_id INTEGER,
    total_sales DECIMAL(15,2),
    total_quantity INTEGER,
    total_orders INTEGER,
    avg_order_value DECIMAL(10,2)
);

CREATE TABLE inventory_movements (
    movement_id INTEGER PRIMARY KEY,
    product_id INTEGER,
    movement_type VARCHAR(20),
    quantity INTEGER,
    unit_cost DECIMAL(10,2),
    movement_date DATE,
    reference_id INTEGER,
    notes VARCHAR(200)
);

CREATE TABLE customer_interactions (
    interaction_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    employee_id INTEGER,
    interaction_type VARCHAR(30),
    interaction_date TIMESTAMP,
    subject VARCHAR(100),
    notes VARCHAR(500),
    follow_up_date DATE
);
```

#### Acceso a Credenciales Dinámicas:
```bash
# Las credenciales se generan automáticamente al iniciar
# Leer desde el volumen montado:
cat ./credentials/teradata_credentials.txt

# Formato del archivo:
# ADMIN_USER=admin_user
# ADMIN_PASS=root
# APP_USER=app_user
# APP_PASS=<generado_aleatoriamente>
# DATABASE=sample_db
# HOST=localhost
# PORT=1025
```

### Imagen 2: API On-Premise (Aplicación)
- **Imagen**: `ghcr.io/theboys2025jmss-creator/api-onprem:latest`
- **Puerto**: 8000
- **Endpoints**: `/health`, `/api/v1/`
- **Configuración**: Variables de entorno para conexión a BD

## Estructura del Repositorio a Crear

```
dataset-repo-name/
├── data/
│   ├── sql/                    # Scripts SQL adicionales
│   ├── csv/                    # Archivos CSV para carga
│   └── json/                   # Archivos JSON para APIs
├── scripts/
│   ├── start.sh               # Script para levantar entorno
│   ├── load-data.sh           # Script para cargar datos
│   └── test-connection.sh     # Script para probar conectividad
├── docker-compose.yml         # Configuración completa del entorno
├── .env.example              # Variables de entorno de ejemplo
├── README.md                 # Documentación del dataset
└── Makefile                  # Comandos útiles
```

## Requerimientos Específicos

### Docker Compose
- **Servicios**: Definir servicios para cada imagen
- **Redes**: Crear red interna para comunicación entre servicios
- **Volúmenes**: Montar datos y credenciales correctamente
- **Health checks**: Verificar que servicios estén listos
- **Dependencias**: API debe esperar a que BD esté lista

### Scripts de Automatización
- **start.sh**: Levantar entorno completo y mostrar credenciales
- **load-data.sh**: Cargar datasets en la base de datos
- **test-connection.sh**: Probar conectividad entre servicios

### Datos de Ejemplo (Auto-carga)
- **SQL**: Scripts que se ejecutan automáticamente al iniciar el contenedor
- **CSV**: Archivos que se cargan automáticamente en las tablas correspondientes
- **JSON**: Datos para endpoints de API
- **Volumen de datos**: Generar entre 200-300 registros por tabla para simular un entorno realista
- **Datos relacionales**: Mantener integridad referencial entre tablas (FK válidas)

#### Formato de Archivos CSV (deben coincidir con esquema completo):
```
# customers.csv (200-300 registros)
customer_id,customer_name,email,phone,address,city,state,country,postal_code,customer_type,credit_limit,created_date,last_updated
1,"Acme Corp","contact@acme.com","+1-555-0123","123 Main St","New York","NY","USA","10001","Corporate",50000.00,"2024-01-15","2024-01-15 10:00:00"

# categories.csv (10-15 registros)
category_id,category_name,description
1,"Electronics","Electronic devices and accessories"

# suppliers.csv (50-100 registros)
supplier_id,supplier_name,contact_name,contact_title,address,city,region,postal_code,country,phone,email
1,"Tech Supply Co","John Smith","Sales Manager","456 Tech Ave","San Francisco","CA","94105","USA","+1-555-0456","john@techsupply.com"

# products.csv (200-300 registros)
product_id,product_name,category_id,supplier_id,unit_price,units_in_stock,units_on_order,reorder_level,discontinued,created_date
1,"Laptop Pro",1,1,1299.99,50,10,5,"N","2024-01-01"

# departments.csv (10-20 registros)
department_id,department_name,manager_id,budget,location
1,"Sales",1,500000.00,"New York Office"

# employees.csv (100-200 registros)
employee_id,last_name,first_name,title,title_of_courtesy,birth_date,hire_date,address,city,region,postal_code,country,home_phone,extension,reports_to,salary,department_id
1,"Johnson","Alice","Sales Manager","Ms.","1985-03-15","2020-01-15","789 Oak St","New York","NY","10002","USA","+1-555-0789","101",NULL,75000.00,1

# shippers.csv (5-10 registros)
shipper_id,company_name,phone,email
1,"Fast Delivery Inc","+1-555-SHIP","info@fastdelivery.com"

# orders.csv (300-500 registros)
order_id,customer_id,employee_id,order_date,required_date,shipped_date,ship_via,freight,ship_name,ship_address,ship_city,ship_region,ship_postal_code,ship_country,order_status,total_amount
1,1,1,"2024-01-20","2024-01-25","2024-01-22",1,15.50,"Acme Corp","123 Main St","New York","NY","10001","USA","Delivered",2599.98

# order_details.csv (500-1000 registros)
order_id,product_id,unit_price,quantity,discount
1,1,1299.99,2,0.05

# sales_summary.csv (200-300 registros)
summary_id,year_month,customer_id,product_id,category_id,total_sales,total_quantity,total_orders,avg_order_value
1,202401,1,1,1,25999.80,20,10,2599.98

# inventory_movements.csv (300-500 registros)
movement_id,product_id,movement_type,quantity,unit_cost,movement_date,reference_id,notes
1,1,"IN",100,1200.00,"2024-01-01",1,"Initial stock"

# customer_interactions.csv (200-400 registros)
interaction_id,customer_id,employee_id,interaction_type,interaction_date,subject,notes,follow_up_date
1,1,1,"Phone Call","2024-01-15 14:30:00","Product Inquiry","Customer interested in bulk purchase","2024-01-20"
```

#### Scripts de Carga Automática:
```sql
-- 02-load-data.sql (se ejecuta después de crear tablas)
\COPY customers FROM '/data/csv/customers.csv' WITH CSV HEADER;
\COPY products FROM '/data/csv/products.csv' WITH CSV HEADER;
\COPY categories FROM '/data/csv/categories.csv' WITH CSV HEADER;
\COPY orders FROM '/data/csv/orders.csv' WITH CSV HEADER;
\COPY order_details FROM '/data/csv/order_details.csv' WITH CSV HEADER;
\COPY employees FROM '/data/csv/employees.csv' WITH CSV HEADER;
```

### Documentación
- **README.md**: Cómo usar el entorno, endpoints disponibles, credenciales
- **Variables de entorno**: Configuración necesaria
- **Ejemplos de uso**: Queries SQL, llamadas a API

## Casos de Uso

Este entorno debe permitir:

1. **Desarrollo**: Probar integraciones localmente
2. **Demos**: Mostrar funcionalidad completa
3. **Testing**: Ejecutar pruebas end-to-end
4. **Capacitación**: Entrenar equipos con datos realistas

## Comandos Esperados

```bash
# Levantar entorno completo
make up

# Cargar datos de ejemplo
make load-data

# Probar conectividad
make test

# Ver logs
make logs

# Limpiar entorno
make down
```

## Integración con AWS (Futuro)

El entorno debe estar preparado para:
- **AWS Glue**: Como fuente de datos para ETL
- **AWS DMS**: Para migración a RDS/Redshift
- **Amazon Athena**: Para queries federadas
- **API Gateway**: Para exponer APIs

## Ejemplo de Uso

```bash
# 1. Clonar repo de dataset
git clone https://github.com/user/dataset-repo-name.git
cd dataset-repo-name

# 2. Levantar entorno (datos se cargan automáticamente)
make up

# 3. Obtener credenciales generadas
cat credentials/teradata_credentials.txt

# 4. Probar conexión a BD
source credentials/teradata_credentials.txt
psql -h localhost -p 1025 -U $APP_USER -d sample_db

# 5. Probar API (si aplica)
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/customers

# 6. Queries de ejemplo
psql -h localhost -p 1025 -U $APP_USER -d sample_db -c "SELECT COUNT(*) FROM customers;"
psql -h localhost -p 1025 -U $APP_USER -d sample_db -c "SELECT * FROM orders LIMIT 5;"
```

## Docker Compose Ejemplo

```yaml
version: '3.8'
services:
  teradata:
    image: ghcr.io/theboys2025jmss-creator/poc-teradata-onprem:latest
    ports:
      - "1025:1025"
    volumes:
      - ./credentials:/tmp/credentials
      - ./data/sql:/docker-entrypoint-initdb.d
      - ./data/csv:/data/csv
    healthcheck:
      test: ["CMD", "pg_isready", "-h", "localhost", "-p", "1025"]
      interval: 30s
      timeout: 10s
      retries: 3

  api:
    image: ghcr.io/theboys2025jmss-creator/api-onprem:latest
    ports:
      - "8000:8000"
    depends_on:
      teradata:
        condition: service_healthy
    environment:
      - DATABASE_URL=postgresql://app_user:app_pass@teradata:1025/sample_db
    volumes:
      - ./credentials:/app/credentials:ro
```

---

**Nota**: Este prompt debe generar un repositorio que funcione con cualquiera de las imágenes Docker disponibles, adaptándose automáticamente según la imagen especificada.