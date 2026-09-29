# GRUPO6_CIIN1021P_EF_REPO
Proyecto integrador de Base de Datos Avanzada y Big Data
#Descripción
Proyecto integrador desarrollado a partir de conjuntos de datos abiertos relacionados con la salud de la región Junín. El proyecto comprende procesos de automatización, seguridad, integración SQL–NoSQL, Data Warehouse, ETL, Business Intelligence y procesamiento Big Data.

#Estructura del repositorio
Proyecto-BD-Datos-Salud-Junin/
│
├── SQL/
├── Automatizacion_SQL/
├── Seguridad/
├── MongoDB/
├── DataWarehouse_ETL/
├── PowerBI/
├── BigData/
└── README.md

#Herramientas utilizadas
SQL Server y SQL Server Management Studio
MongoDB Compass
Python y Google Colab
Power BI
PySpark
GitHub

#Configuración para SQL Server
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
