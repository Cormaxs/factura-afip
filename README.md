# Toda la información está sacada de [AFIP - ARCA](https://www.afip.gob.ar/ws/)

## proyecto de factura electronica

Empezar leyendo el pdf para desarrolladores [aquí](https://www.afip.gob.ar/fe/ayuda/documentos/WSSEG-ManualParaElDesarrollador_ARCA-0.9.pdf)

* ARCA permite 2 modos, el de **omologcion o testing**(recomendable para pruebas) y el de **producción**
* Recomiendo primero ir a la [documentación](https://www.afip.gob.ar/ws/documentacion/arquitectura-general.asp) 

## Arquitectura general de los procesos

![Image Alt](./components-readme/arquitectura-general.png)

-1 solicitar ticket de acceso a un WSN
Vamos a necesitar tener instalados los programas

*[Openssl](https://slproweb.com/products/Win32OpenSSL.html) -> le dan click al primero que les salga [Image Alt](./components-readme/openssl-donwload.png)
una ves instalado necesitamos Editar las variables de entorno de windows, la ruta que deben poner es (recomiendo que creen la ruta(path) en sistema y no para usuario):

```bash
C:\Program Files\OpenSSL-Win64\bin
```

despues abren CMD y ponen

```bash
openssl --version
```

una ves instalado onpenssl nos vamos a leer el manual de [certificados](https://www.afip.gob.ar/ws/WSASS/WSASS_manual.pdf)