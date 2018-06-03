function! kronos#GetConfig()
  return {
    \'gui': {
      \'label': {
        \'active': 'ACTIVE',
        \'desc'  : 'DESC',
        \'due'   : 'DUE',
        \'id'    : 'ID',
        \'tags'  : 'TAGS',
      \},
      \'order': [
        \'id',
        \'desc',
        \'tags',
        \'active',
        \'due',
      \],
      \'width': {
        \'active': 13,
        \'desc'  : 30,
        \'due'   : 13,
        \'id'    : 5,
        \'tags'  : 19,
      \},
    \},
  \}
endfunction

