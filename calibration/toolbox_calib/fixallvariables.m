% Code that clears all empty or NaN variables

varlist = whos;

if ~isempty(varlist),
    
    Nvar = size(varlist,1);
    
    for c_var = 1:Nvar,
        
        var2fix = varlist(c_var).name;
        
        fixvariable;
        
    end;
    
end;

clear varlist var2fix Nvar c_var