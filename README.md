# GRUPO6_CIIN1021P_EF_REPO
Proyecto integrador desarrollado a partir de conjuntos de datos abiertos relacionados con la salud de la región Junín. El proyecto comprende procesos de automatización, seguridad, integración SQL–NoSQL, Data Warehouse, ETL, Business Intelligence y procesamiento Big Data.

## 📁 Estructura del repositorio
El repositorio se encuentra organizado en carpetas según los componentes desarrollados durante el proyecto:
```text
Proyecto-BD-Datos-Salud-Junin/
│
├── 📁 SQL/
├── 📁 Automatizacion_SQL/
├── 📁 Seguridad/
├── 📁 MongoDB/
├── 📁 DataWarehouse_ETL/
├── 📁 PowerBI/
├── 📁 BigData/
│
└── 📄 README.md
```
Cada carpeta contiene los archivos correspondientes a la etapa del proyecto:
* **SQL:** dataset y archivos necesarios para la implementación en SQL Server.
* **Automatizacion_SQL:** procedimientos almacenados, triggers, funciones y tablas utilizadas en la automatización.
* **Seguridad:** roles, permisos, respaldos, restauración e índices.
* **MongoDB:** archivos relacionados con la implementación y operaciones CRUD.
* **DataWarehouse_ETL:** modelo dimensional y proceso ETL.
* **PowerBI:** dashboard y consultas utilizadas para los indicadores.
* **BigData:** notebook de PySpark y comparación de tiempos con SQL Server.
## ⚙️ Configuración para SQL Server

La carpeta `SQL` contiene el dataset utilizado por la implementación en SQL Server y los archivos necesarios para realizar la carga de los datos.

### Requisitos

* SQL Server.
* SQL Server Management Studio (SSMS).
* Acceso al repositorio del proyecto.

### Pasos de configuración

1. Descargar o clonar este repositorio.
2. Copiar la carpeta `SQL` directamente en el **disco local C:** del computador.
3. Verificar que la carpeta se encuentre en la siguiente ubicación:

```text
C:\SQL\
```

4. Verificar que el dataset se encuentre en:

```text
C:\SQL\Dataset_Salud_BigData.csv
```

5. Abrir **SQL Server Management Studio (SSMS)**.
6. Ejecutar los scripts contenidos en la carpeta `Automatizacion_SQL`.

### Importación del dataset

La implementación utiliza `BULK INSERT` para cargar el dataset desde el archivo CSV. Por este motivo, es necesario mantener la ruta indicada anteriormente.

```sql
BULK INSERT stg_Gestantes
FROM 'C:\SQL\Dataset_Salud_BigData.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
```

> **Importante:** La ruta `C:\SQL\Dataset_Salud_BigData.csv` debe mantenerse para que el script de carga pueda encontrar correctamente el archivo.
