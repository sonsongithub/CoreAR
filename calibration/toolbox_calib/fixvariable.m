% Code that clears an empty variable, or a NaN vsriable.
% Does not clear structures, or cells.

if exist('var2fix')==1,
    if   eval(['exist(''' var2fix ''') == 1']),
        if eval(['isempty(' var2fix ')']),
            eval(['clear ' var2fix ]);
        else
            if eval(['~isstruct(' var2fix ')']),
                if eval(['~iscell(' var2fix ')']),
                    if eval(['isnan(' var2fix '(1))']),
                        eval(['clear ' var2fix ]);
                    end; 
                end;
            end;
        end;
    end;
end;
