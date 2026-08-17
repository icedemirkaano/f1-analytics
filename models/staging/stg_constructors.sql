select
    constructorId   as constructor_id,
    constructorRef  as constructor_ref,
    name            as constructor_name,
    nationality     as nationality
from {{ source('raw_f1', 'constructors') }}