Orden sugerido para ejecutar los archivos:

1. nuevas_tablas.sql
2. inserts.sql
3. functions.sql
4. triggers.sql
5. stored_procedures.sql
6. views.sql

IMPORTANTE: Los triggers deben crearse DESPUÉS de los inserts.
Estamos cargando datos históricos de la base. Los clientes con
suscripción vencida tienen sesiones registradas de cuando su
suscripción estaba activa. Los triggers se crean después para
que no bloqueen la carga de estos datos históricos y comiencen
a funcionar solo para operaciones futuras.