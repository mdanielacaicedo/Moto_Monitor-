 CONTRIBUTORS
============

Listado de personas que han contribuido a este repositorio.

Formato recomendado:

- Nombre Completo <email@example.com> — rol / breve descripción

Ejemplo:

- Juan Pérez <juan.perez@example.com> — Desarrollo frontend y lógica de negocio
- María Gómez <maria.gomez@example.com> — Diseño de base de datos y pruebas

Cómo garantizar que aparezcan en el historial de commits
------------------------------------------------------

1) Si la persona ya tiene commits locales:

   - Que suba (push) su rama al remoto: `git push origin su-rama`
   - Luego fusiona o hace rebase a `main` para que sus commits queden en el historial.

2) Si quieres crear commits en su nombre (desde una sola máquina):

   - Crear commit con autor explícito:

       git add <archivos>
       git commit --author="Nombre Otro <otro@example.com>" -m "Descripción de la contribución"

   - O añadir `Co-authored-by` en el mensaje del commit:

       git commit -m "Mensaje\n\nCo-authored-by: Nombre Otro <otro@example.com>"

3) Para añadir `Co-authored-by` a un commit existente:

   - `git commit --amend -m "Mensaje original\n\nCo-authored-by: Nombre Otro <otro@example.com>"`
   - `git push --force-with-lease` (con precaución)

Notas
-----

- Modificar el historial (rebase/amend + force push) puede afectar a otros colaboradores; coordina antes.
- Para repositorios privados o entregas académicas, guarda evidencia adicional (pull requests, issues, mensajes) que muestren la colaboración.

