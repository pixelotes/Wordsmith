# ⚒️ Wordsmith

**Wordsmith** es un generador de diccionarios (wordlists) automatizado escrito en Bash. 

Esta herramienta recorre recursivamente directorios, extrae texto de múltiples formatos de archivo (documentos, código, webs), limpia los datos y genera una lista de palabras única, normalizada y ordenada. Ideal para crear diccionarios personalizados para pruebas de fuerza bruta (CTF, Pentesting) basados en la documentación objetivo.

## 🚀 Características

* **Recursivo:** Busca en carpetas y subcarpetas.
* **Multiformato:** Soporta `.txt`, `.md`, `.json`, `.xml`, `.sql`, `.html`, `.pdf`, `.doc`, `.docx`, `.odt` y más.
* **Inteligente con PDFs:** Utiliza `pdftotext` para una extracción limpia, con fallback a `strings` si no está instalado.
* **Normalización:**
    * Convierte todo a minúsculas.
    * Elimina tildes y caracteres especiales (transliteración: á -> a, ñ -> n).
    * Filtra palabras por longitud (4 a 20 caracteres).
* **Eficiente:** Utiliza tuberías (pipelines) de Linux para procesar grandes volúmenes de datos rápidamente.

## 📋 Requisitos

* Un entorno **Linux** (Bash).
* **(Recomendado)** `poppler-utils` para una mejor extracción de PDFs.

Si no lo tienes instalado:
```bash
sudo apt update && sudo apt install poppler-utils
```

## ⚙️ Instalación
Descarga el script o crea el archivo:

```bash
nano Wordsmith.sh
```

Dale permisos de ejecución:

```bash
chmod +x Wordsmith.sh
`````

## 💻 Uso

La sintaxis básica es: ./Wordsmith.sh [DIRECTORIO_ORIGEN] [ARCHIVO_SALIDA]

Ejemplos
1. Escanear el directorio actual (por defecto): Genera el diccionario diccionario_moodle.txt basándose en los archivos de la carpeta donde estás.

```bash
./Wordsmith.sh
```

2. Escanear una carpeta específica: Escanea /home/usuario/documentos y guarda el resultado en wordlist.txt.

```bash
./Wordsmith.sh /home/usuario/documentos wordlist.txt
```

## 📂 Extensiones Soportadas

Wordsmith busca automáticamente las siguientes extensiones:

* Texto/Código: .txt, .md, .csv, .json, .xml, .sql, .log
* Web: .html, .htm, .xhtml
* Documentos: .pdf, .doc, .docx, .rtf, .odt

Nota: Para archivos binarios como .doc (Word antiguo) o si falla la lectura de un PDF, la herramienta utiliza el comando strings para intentar recuperar texto legible.

## ⚠️ Aviso Legal
Esta herramienta ha sido creada con fines educativos y de auditoría de seguridad. El uso de este script para atacar sistemas sin consentimiento previo es ilegal. El autor no se hace responsable del mal uso de esta herramienta.
