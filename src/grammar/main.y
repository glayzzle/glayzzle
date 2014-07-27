%start expr


%% /* language grammar */

expr
    : ANY_CHAR EOF
        {print($1); return $1;}
    ;