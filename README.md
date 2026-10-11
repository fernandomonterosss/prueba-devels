# qr_app_devels

Es una app para uso offline y online en el cual se descarga un catalogo de productos para luego crear pedidos/ordenes, utiliza un lector de QR para facilitar las busqueda de algun producto en especifico.

## Requerimientos

Para este proyecto se utilizaron las siguientes:
* Flutter 3.10.7 
* Java 26 

## Instalación

Para instalar librerias y paquetes que contiene el proyecto dentro del directorio qr_app_devels ejecutamos el siguiente comando:

* flutter pub get

Esto instalara todas las librerias necesarias para poder correr el proyecto localmente.

## Dependencias
El sdk del lector QR se realizo utilizando librerias nativas como ayuda por lo tanto las validaciones, permisos y el parseo de resultados son lo mas importante dentro de este SDK nativo llamado QrLibrary. Para implementarlo dentro del proyecto de qr_app_devels se genero un puente con flutter utilizando methodChannels y se genero el archivo ".aar". Luego ese archivo se coloco dentro del directorio android/libs para poder ser utilizado desde cualquier parte de la aplicación.


## Entregables

Para poder ver el release y descargar el apk haga clic en el siguiente enlace [aquí](https://github.com/fernandomonterosss/prueba-devels/releases/tag/V1.0.0) y para ver el video de demostración [video](https://drive.google.com/drive/folders/1xE4hQfaqQysw9rbnWQYx3gOthLzELUr5?usp=sharing)

