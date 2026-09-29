# GRUPO6_CIIN1021P_EF_REPO
Proyecto integrador de Base de Datos Avanzada y Big Data
#Descripción
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

##Configuración para SQL Server
La carpeta SQL contiene el dataset utilizado por la implementación en SQL Server y los archivos necesarios para realizar la carga de los datos.
Para ejecutar correctamente los scripts:
Descargar o clonar el repositorio.
Copiar la carpeta SQL directamente en el disco local C: del computador.
Verificar que la ruta sea:
C:\SQL\
Ejecutar los scripts de implementación en SQL Server Management Studio (SSMS).
La ubicación es necesaria debido a que el proceso de carga utiliza la ruta:
C:\SQL\Dataset_Salud_BigData.csv
para importar el dataset mediante BULK INSERT.
