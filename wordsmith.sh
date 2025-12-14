#!/bin/bash

# ==============================================================================
# 🛠️ CONFIGURACIÓN Y PARÁMETROS
# ==============================================================================
PATH_DIR="${1:-.}"                  # Primer argumento: Carpeta a escanear (default: actual)
OUTPUT="${2:-diccionario_moodle.txt}" # Segundo argumento: Archivo de salida

# Colores para visualización
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[1;30m'
NC='\033[0m' # No Color

echo -e "📚 Generando diccionario desde: $PATH_DIR"

# Regex para capturar palabras (4 a 20 letras, incluye tildes)
REGEX="[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ]{4,20}"

# ==============================================================================
# 🔍 VERIFICAR DEPENDENCIAS (pdftotext)
# ==============================================================================
# Intentamos localizar la herramienta estándar de Linux para PDFs
PDF_CMD=""

if command -v pdftotext &> /dev/null; then
    PDF_CMD="pdftotext"
    echo -e "${GREEN}✔️ pdftotext encontrado (paquete poppler-utils).${NC}"
else
    echo -e "${YELLOW}⚠️ pdftotext no encontrado. Se usará 'strings' como alternativa básica.${NC}"
    echo -e "${GRAY}   (Para mejor resultados: sudo apt install poppler-utils)${NC}"
fi

# ==============================================================================
# 🧠 FUNCIÓN DE EXTRACCIÓN DE TEXTO
# ==============================================================================
extract_text() {
    local file="$1"
    local filename=$(basename "$file")
    local ext=".${filename##*.}"
    ext="${ext,,}" # Convertir extensión a minúsculas

    case "$ext" in
        # Archivos de texto plano y código
        .txt|.md|.csv|.json|.xml|.sql|.log)
            cat "$file" 2>/dev/null
            ;;
        
        # Archivos Web (quitamos tags HTML básicos)
        .html|.htm|.xhtml)
            sed 's/<[^>]*>/ /g' "$file" 2>/dev/null
            ;;
        
        # Archivos PDF
        .pdf)
            if [ -n "$PDF_CMD" ]; then
                # IMPORTANTE: El guion final "-" envía el texto a pantalla (stdout)
                # -layout mantiene un poco el formato para evitar pegar palabras
                "$PDF_CMD" -layout "$file" - 2>/dev/null
            else
                # Fallback si no hay pdftotext
                strings "$file"
            fi
            ;;
        
        # Todo lo demás (DOC, DOCX, Binarios)
        # 'strings' extrae secuencias de caracteres imprimibles de cualquier binario
        *)
            strings "$file"
            ;;
    esac
}

# ==============================================================================
# 🚀 EJECUCIÓN PRINCIPAL (PIPELINE)
# ==============================================================================

# 1. Buscamos archivos con 'find'
# 2. Leemos archivo por archivo en el bucle
# 3. Extraemos texto -> Filtramos con Grep -> Normalizamos -> Ordenamos

find "$PATH_DIR" -type f \( \
    -iname "*.txt" -o -iname "*.md" -o -iname "*.csv" -o -iname "*.json" -o -iname "*.xml" -o -iname "*.log" -o -iname "*.sql" -o \
    -iname "*.htm" -o -iname "*.html" -o -iname "*.xhtml" -o \
    -iname "*.doc" -o -iname "*.docx" -o -iname "*.rtf" -o -iname "*.odt" -o \
    -iname "*.pdf" \
\) | while read -r file; do
    
    # Mensaje de progreso (stderr para no ensuciar la tubería de datos)
    echo -e "${GRAY}Leyendo: $file${NC}" >&2
    
    # Extraer contenido crudo
    content=$(extract_text "$file")
    
    # Filtrar solo las palabras que coinciden con la Regex
    # -o: Only matching (solo la palabra, no la línea entera)
    # -E: Regex extendido
    echo "$content" | grep -oE "$REGEX"

done | \
# --- FASE DE PROCESAMIENTO FINAL ---
tr '[:upper:]' '[:lower:]' |      # 1. Todo a minúsculas
sed 'y/áéíóúüñ/aeiouun/' |        # 2. Quitar tildes (transliteración)
sort -u > "$OUTPUT"               # 3. Ordenar y eliminar duplicados

# ==============================================================================
# ✅ FINALIZACIÓN
# ==============================================================================
if [ -f "$OUTPUT" ]; then
    COUNT=$(wc -l < "$OUTPUT")
    echo -e "${GREEN}✅ Proceso terminado.${NC}"
    echo "📄 Diccionario guardado en: $OUTPUT"
    echo "📊 Palabras únicas: $COUNT"
else
    echo -e "${YELLOW}⚠️ No se encontraron palabras o hubo un error al escribir el archivo.${NC}"
fi
