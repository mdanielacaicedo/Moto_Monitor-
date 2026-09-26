Proyecto de gestion Moto_Montor
================================

Resumen
-------
Proyecto Flutter para la gestión de motos. Este repositorio contiene la aplicación, tests y assets.

Objetivo de este README
-----------------------
Este README explica cómo:

- Preparar el repositorio para subirlo a GitHub/GitLab.
- Asegurar que el historial de commits incluya a ambos integrantes.
- Ejecutar la aplicación localmente.

Checklist rápida (pasos recomendados)
-----------------------------------

1. Verificar el estado del repo local y las ramas:

   git status
   git branch --show-current

2. Asegurar que ambos integrantes tengan commits en la historia:
   - Si el otro integrante ya tiene commits en otra copia/local, pedir que suba su rama o enviarle un parche.
   - Si no, crear commits con el autor del otro integrante o usar co-authored-by (ver más abajo).

3. Crear el repositorio remoto (GitHub/GitLab) y enlazarlo:

   git remote add origin https://github.com/usuario/nombre-repo.git
   git branch -M main
   git push -u origin main

4. Incluir un `CONTRIBUTORS.md` y este README actualizado (ya incluidos).

Cómo ejecutar la app localmente (resumen)
--------------------------------------

Requisitos: Flutter (stable), Android SDK / Xcode según la plataforma.

Comandos básicos:

PowerShell (Windows):

   flutter pub get
   flutter run

Tests:

   flutter test

Garantizar el historial de commits de ambos integrantes
----------------------------------------------------

Situación A — ambos ya hicieron commits localmente en sus máquinas:

1. Cada integrante debe empujar (push) sus ramas al remoto o enviar un patch (git format-patch).
2. Hacer merge o rebase para que la rama `main` tenga los commits de ambos.

Situación B — uno de los integrantes no tiene commits pero necesita aparecer en el historial:

Opción 1 — Commit en nombre del otro:

   git add <archivos>
   git commit --author="Nombre Otro <otro@example.com>" -m "Describir contribución de Otro"
   git push

Esto crea un commit cuyo autor es el otro integrante.

Opción 2 — Añadir "Co-authored-by" a un commit existente (recomendado si la contribución fue conjunta):

   git commit -m "Mensaje de commit\n\nCo-authored-by: Nombre Otro <otro@example.com>"

Para añadir la etiqueta a la última confirmación:

   git commit --amend -m "Mensaje original\n\nCo-authored-by: Nombre Otro <otro@example.com>"
   git push --force-with-lease

Advertencias sobre reescritura de historial
------------------------------------------

- Evita usar force-push si otras personas ya han basado trabajo en la rama remota. Comunica antes.
- Para cambiar autores de commits antiguos puedes usar `git rebase -i --root` y `git commit --amend --author="..."`, pero es avanzado.

Comandos útiles para verificar autores y historial
-------------------------------------------------

Listar autores y número de commits:

   git shortlog -sne

Log con autor y email:

   git log --pretty=format:"%h %an <%ae> %ad %s" --date=short

Buscar commits de un autor específico:

   git log --author="Nombre Otro"

Archivo `CONTRIBUTORS.md`
------------------------
Se incluye un archivo `CONTRIBUTORS.md` en la raíz con información sobre los integrantes y cómo confirmar la autoría en commits.

Pasos finales para publicar en GitHub/GitLab
-------------------------------------------

1. Crear el repo en GitHub/GitLab via web UI.
2. Enlazar remoto y pushear (comandos más arriba).
3. En la web, añadir al otro integrante como colaborador o miembro del proyecto para que puedan empujar directamente.

Soporte
-------
Si quieres, puedo:

- Generar y rellenar `CONTRIBUTORS.md` con los nombres y emails.
- Preparar una rama ejemplo con commits etiquetados como co-authored para que puedas ver cómo queda el historial.
- Ayudarte a crear el repo remoto desde la línea de comandos (si me das consentimiento para usar tus credenciales en el entorno). 

Indica qué prefieres que haga ahora y lo hago.

