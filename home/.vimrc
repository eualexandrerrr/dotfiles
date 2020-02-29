syntax on
set autoread
set showmode

set showcmd " Mostrar comando (parcial) na linha de status.
set showmatch " Mostrar colchetes correspondentes.
set ignorecase " Fazer correspondência sem distinção entre maiúsculas e minúsculas
set smartcase " Do smart case matching
set incsearch " Incremental search
set autowrite " Automatically save before commands like :next and :make
set hidden " Hide buffers when they are abandoned
set mouse=a " Enable mouse usage (all modes)

set cursorline
hi CursorLine term=none cterm=bold
highlight CursorLine guibg=#0B0C0D ctermbg=234
