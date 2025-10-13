#!/bin/bash
# Bulk script: html post-processing
# Performs backup, make, rename files and string replacements
# 

BAK_DIR="bak"
SRC_DIR="html"
OUT_DIR="."

EDIT_TIME=$([[ -n "$1" ]] && echo "$1" || date "+%Y-%m-%d %H:%M:%S%z")
BASE_URL="https://e2se.github.io/e2se-seeds"
REPO_TREE_URL="https://github.com/e2se/e2se-seeds/tree/main"
REPO_BLOB_URL="https://github.com/e2se/e2se-seeds/blob/main"
TPL_META_DESC="<meta name=\"description\" content=\"%s\">"
TPL_META_LINKH="<link rel=\"home\" href=\"%s\">"
TPL_META_LINKI="<link rel=\"index\" href=\"%s\">"
TPL_META_LINKS="<link rel=\"contents\" href=\"%s\">"
TPL_META_LINKC="<link rel=\"canonical\" href=\"$BASE_URL/%s\">"
TPL_FOOT_LE="Source File: <b><a href=\"$REPO_TREE_URL/%s\">%s</a></b><br>"
TPL_FOOT_DT="Datetime: <b>%s</b><br>"
TPL_FOOT_RE0="Content Type: <b>seeds (source file)</b><br>\nLicense: <a href=\"$REPO_BLOB_URL/LICENSE-MIT\">MIT License</a><br>\nLicense: <a href=\"$REPO_BLOB_URL/LICENSE-GPL-3.0-or-later\">GNU GPLv3 License</a><br>"
TPL_FOOT_RE1="<p>\nNotes: <br><br>\n<i>All brands, logos, trademarks and registered trademarks are property of their copyright holders.</i>"
TPL_NAV="<nav>\n<a href=\"%s\">&crarr; Parent Document</a>\n</nav>"
TPL_INDEX_TROW="<tr><td class=\"trid\"><a href=\"%s\">%s</a></td><td>%s</td></tr>"
TPL_BOUQUETS_TROW="<tr><td class=\"trid\">%d</td><td>%s</td><td><a href=\"%s\">%s</a></td><td>%s</td><td>%s</td></tr>"


## backup
if TRUE; then
mkdir -p "$BAK"
mv "$OUT_DIR/"*.html "$BAK/"
fi


## blacklist.html whitelist.html
if TRUE; then
touch "$OUT_DIR/"{blacklist,whitelist}.html
fi


IFS=$'\n'

## index.html
if TRUE; then
filename="index"
src="index.html"
dst="${filename//\./-}.html"
FILE=$(cat "$SRC_DIR/$src")
HTML=""
META="$TPL_META_DESC\n$TPL_META_LINKH\n$TPL_META_LINKC\n"
META=$(printf "$META" "Seeds source, Settings Enigma 2 Lamedb, Index" "$BASE_URL/" "")
NAV=$(printf "$TPL_NAV" "$BASE_URL/")
FOOT_DT=$(printf "$TPL_FOOT_DT" "$EDIT_TIME")
FOOT_RE="$TPL_FOOT_RE1"
i=0
for line in $FILE; do
    if [[ "$line" == *"name=\"generator\""* ]]; then
        continue
    elif [[ "$line" == *"<title>"* ]]; then
        line=$(printf "<title>%s</title>" "Seeds Index")
    elif [[ "$line" == "<style>"* ]]; then
        line="$META\n$line"
    elif [[ "$line" == "<h3>"* ]]; then
        line="${line/index\.html/Index}"
    elif [[ $i == 0 && "$line" == "</div>"* ]]; then
        i=1
        line="$NAV\n$line"
    elif [[ "$line" == "<tbody>"* ]]; then
        line=$(printf "$line\n$TPL_INDEX_TROW\n" "enigma_db.html" "enigma_db" "Enigma 2 settings")
    elif [[ "$line" == *"class=\"trid\""* ]]; then
        continue
    elif [[ "$line" == "Editor: "* ]]; then
        continue
    elif [[ "$line" == "Datetime: "* ]]; then
        line="$FOOT_DT\n$FOOT_RE"
    fi
    HTML="$HTML$line\n"
done

echo -e "$HTML" > "$OUT_DIR/$dst"
fi


## enigma_db.html
if TRUE; then
filename="enigma_db"
src="index.html"
dst="${filename//\./-}.html"
FILE=$(cat "$SRC_DIR/$src")
HTML=""
META="$TPL_META_DESC\n$TPL_META_LINKI\n$TPL_META_LINKC\n"
META=$(printf "$META" "Enigma 2 settings, Table of Contents, Source file: $filename" "index.html" "$dst")
NAV=$(printf "$TPL_NAV" "index.html")
FOOT_LE=$(printf "$TPL_FOOT_LE" "$filename" "$filename")
FOOT_DT=$(printf "$TPL_FOOT_DT" "$EDIT_TIME")
FOOT_RE="$TPL_FOOT_RE0\n$TPL_FOOT_RE1"
i=0
for line in $FILE; do
    if [[ "$line" == "<style>"* ]]; then
        line="$META\n$line"
    elif [[ $i == 0 && "$line" == "</div>"* ]]; then
        i=1
        line="$NAV\n$line"
    elif [[ "$line" == *"class=\"trid\""* ]]; then
        NAME="${line#*<td class=\"trid\">}"
        NAME="${NAME%%</td>*}"
        PAGE="${NAME//\./-}.html"
        TYPE="${line#*</td><td>}"
        TYPE="${TYPE%</td>}"
        if [[ "$NAME" == "lamedb5" ]]; then
            PAGE="lamedb.html"
        fi
        if [[ "$NAME" != *"list"* ]]; then
            line=$(printf "$TPL_INDEX_TROW\n" "$PAGE" "$NAME" "$TYPE")
        fi
    elif [[ "$line" == "File: "* ]]; then
        line="$FOOT_LE"
    elif [[ "$line" == "Datetime: "* ]]; then
        line="$FOOT_DT\n$FOOT_RE"
    elif [[ "$line" == *"index.html"* ]]; then
        line="${line/index\.html/enigma_db}"
    fi
    HTML="$HTML$line\n"
done

echo -e "$HTML" > "$OUT_DIR/$dst"
fi


## lamedb.html
if TRUE; then
filename="lamedb"
src="services.html"
dst="${filename//\./-}.html"
FILE=$(cat "$SRC_DIR/$src")
HTML=""
META="$TPL_META_DESC\n$TPL_META_LINKS\n$TPL_META_LINKC\n"
META=$(printf "$META" "Services list, Lamedb Settings, Source file: $filename" "enigma_db.html" "$dst")
NAV=$(printf "$TPL_NAV" "enigma_db.html")
FOOT_LE=$(printf "$TPL_FOOT_LE" "enigma_db/$filename" "$filename")
FOOT_DT=$(printf "$TPL_FOOT_DT" "$EDIT_TIME")
FOOT_RE="$TPL_FOOT_RE0\n$TPL_FOOT_RE1"
i=0
for line in $FILE; do
    if [[ "$line" == "<style>"* ]]; then
        line="$META\n$line"
    elif [[ $i == 0 && "$line" == "</div>"* ]]; then
        i=1
        line="$NAV\n$line"
    elif [[ "$line" == "File: "* ]]; then
        line="$FOOT_LE"
    elif [[ "$line" == "Datetime: "* ]]; then
        line="$FOOT_DT\n$FOOT_RE"
    fi
    HTML="$HTML$line\n"
done

echo -e "$HTML" > "$OUT_DIR/$dst"
fi


## atsc-xml.html cables-xml.html satellites-xml.html terrestrial-xml.html
if TRUE; then
for filename in "atsc.xml" "cables.xml" "satellites.xml" "terrestrial.xml"; do
    src="${filename//\./-}.html"
    dst="$src"
    TYPE="${filename%%\.*}"
    if [[ "$TYPE" == "atsc" ]]; then
        TYPE=$(echo "$TYPE" | tr "[:lower:]" "[:upper:]")
    else
        if [[ "$TYPE" != "terrestrial" ]]; then
            TYPE="${TYPE%s}"
        fi
        TYPE=$(echo "${TYPE::1}" | tr "[:lower:]" "[:upper:]")$(echo "${TYPE:1}")
    fi
    FILE=$(cat "$SRC_DIR/$src")
    HTML=""
    META="$TPL_META_DESC\n$TPL_META_LINKS\n$TPL_META_LINKC\n"
    META=$(printf "$META" "Tuner settings, Tuner type: $TYPE, Source file: $filename" "enigma_db.html" "$dst")
    NAV=$(printf "$TPL_NAV" "enigma_db.html")
    FOOT_LE=$(printf "$TPL_FOOT_LE" "enigma_db/$filename" "$filename")
    FOOT_DT=$(printf "$TPL_FOOT_DT" "$EDIT_TIME")
    FOOT_RE="$TPL_FOOT_RE0\n$TPL_FOOT_RE1"
    i=0
    for line in $FILE; do
        if [[ "$line" == "<style>"* ]]; then
            line="$META\n$line"
        elif [[ $i == 0 && "$line" == "</div>"* ]]; then
            i=1
            line="$NAV\n$line"
        elif [[ "$line" == "File: "* ]]; then
            line="$FOOT_LE"
        elif [[ "$line" == "Datetime: "* ]]; then
            line="$FOOT_DT\n$FOOT_RE"
        fi
        HTML="$HTML$line\n"
    done

    echo -e "$HTML" > "$OUT_DIR/$dst"
done
fi


## bouquets-tv.html bouquets-radio.html
if TRUE; then
for filename in "bouquets.tv" "bouquets.radio"; do
    src="${filename//\./-}.html"
    dst="$src"
    TYPE="${filename##*\.}"
    if [[ "$TYPE" == "tv" ]]; then
        TYPE=$(echo "$TYPE" | tr "[:lower:]" "[:upper:]")
    else
        TYPE=$(echo "${TYPE::1}" | tr "[:lower:]" "[:upper:]")$(echo "${TYPE:1}")
    fi
    FILE=$(cat "$SRC_DIR/$src")
    HTML=""
    META="$TPL_META_DESC\n$TPL_META_LINKS\n$TPL_META_LINKC\n"
    META=$(printf "$META" "Bouquet index, Bouquet type: $TYPE, Source file: $filename" "enigma_db.html" "$dst")
    NAV=$(printf "$TPL_NAV" "enigma_db.html")
    FOOT_LE=$(printf "$TPL_FOOT_LE" "enigma_db/$filename" "$filename")
    FOOT_DT=$(printf "$TPL_FOOT_DT" "$EDIT_TIME")
    FOOT_RE="$TPL_FOOT_RE0\n$TPL_FOOT_RE1"
    i=0
    for line in $FILE; do
        if [[ "$line" == "<style>"* ]]; then
            line="$META\n$line"
        elif [[ $i == 0 && "$line" == "</div>"* ]]; then
            i=1
            line="$NAV\n$line"
        elif [[ "$line" == *"class=\"trid\""* ]]; then
            INDEX="${line#*<td class=\"trid\">}"
            INDEX="${INDEX%%</td>*}"
            BOUQUET="${line#*</td><td>}"
            line="$BOUQUET"
            BOUQUET="${BOUQUET%%</td>*}"
            NAME="${line#*</td><td>}"
            line="$NAME"
            NAME="${NAME%%</td>*}"
            PAGE="${NAME//\./-}.html"
            USERBOUQUET="${line#*</td><td>}"
            line="$USERBOUQUET"
            USERBOUQUET="${USERBOUQUET%%</td>*}"
            TYPE="${TYPE#*</td><td>}"
            TYPE="${TYPE%</td>}"
            if [[ "$TYPE" != "TV" ]]; then
                TYPE=$(echo "${TYPE::1}")$(echo "${TYPE:1}" | tr "[:upper:]" "[:lower:]")
            fi
            line=$(printf "$TPL_BOUQUETS_TROW\n" "$INDEX" "$BOUQUET" "$PAGE" "$NAME" "$USERBOUQUET" "$TYPE")
        elif [[ "$line" == "File: "* ]]; then
            line="$FOOT_LE"
        elif [[ "$line" == "Datetime: "* ]]; then
            line="$FOOT_DT\n$FOOT_RE"
        fi
        HTML="$HTML$line\n"
    done

    #FIX
    HTML="${HTML/<tr><div class=\"bouquet\">/<div class=\"bouquet\">}"

    echo -e "$HTML" > "$OUT_DIR/$dst"
done
fi


## userbouquet*
if TRUE; then
for filename in "$SRC_DIR/userbouquet"*; do
    src="${filename##*/}"
    dst="$src"
    filename="${src%%\.*}"
    filename="${filename//-/.}"
    TYPE="${filename##*\.}"
    if [[ "$TYPE" == "tv" ]]; then
        TYPE=$(echo "$TYPE" | tr "[:lower:]" "[:upper:]")
    else
        TYPE=$(echo "${TYPE::1}" | tr "[:lower:]" "[:upper:]")$(echo "${TYPE:1}")
    fi
    FILE=$(cat "$SRC_DIR/$src")
    HTML=""
    META="$TPL_META_DESC\n$TPL_META_LINKS\n$TPL_META_LINKC\n"
    META=$(printf "$META" "Channels List, Bouquet type: $TYPE, Source file: $filename" "enigma_db.html" "$dst")
    NAV=$(printf "$TPL_NAV" "enigma_db.html")
    FOOT_LE=$(printf "$TPL_FOOT_LE" "enigma_db/$filename" "$filename")
    FOOT_DT=$(printf "$TPL_FOOT_DT" "$EDIT_TIME")
    FOOT_RE="$TPL_FOOT_RE0\n$TPL_FOOT_RE1"
    i=0
    for line in $FILE; do
        if [[ "$line" == "<style>"* ]]; then
            line="$META\n$line"
        elif [[ $i == 0 && "$line" == "</div>"* ]]; then
            i=1
            line="$NAV\n$line"
        elif [[ "$line" == "File: "* ]]; then
            line="$FOOT_LE"
        elif [[ "$line" == "Datetime: "* ]]; then
            line="$FOOT_DT\n$FOOT_RE"
        fi
        HTML="$HTML$line\n"
    done

    echo -e "$HTML" > "$OUT_DIR/$dst"
done
fi

