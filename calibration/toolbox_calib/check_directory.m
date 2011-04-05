% This small script looks in the direcory and checks if the images are there.
%
% This works only on Matlab 5.x (otherwise, the dir commands works differently)

% (c) Jean-Yves Bouguet - Dec. 27th, 1999

l = dir([calib_name '*']);

Nl = size(l,1);
Nima_valid = 0;
ind_valid = [];
loc_extension = [];
length_name = size(calib_name,2);

if Nl > 0,
    
    for pp = 1:Nl,
        
        filenamepp =  l(pp).name;
        if isempty(calib_name),
            iii = 1;
        else
            iii = findstr(filenamepp,calib_name);
        end;
        
        loc_ext = findstr(filenamepp,format_image);
        string_num = filenamepp(length_name+1:loc_ext - 2);
        
        if isempty(str2num(string_num)),
            iii = [];
        end;
        
        
        if ~isempty(iii),
            if (iii(1) ~= 1),
                iii = [];
            end;
        end;
        
        
        
        if ~isempty(iii) & ~isempty(loc_ext),
            
            Nima_valid = Nima_valid + 1;
            ind_valid = [ind_valid pp];
            loc_extension = [loc_extension loc_ext(1)];
            
        end;
        
    end;
    
    if (Nima_valid==0),
        
        % try the upper case format:
        
        format_image = upper(format_image);
        
        
        
        for pp = 1:Nl,
            
            filenamepp =  l(pp).name;
            
            if isempty(calib_name),
                iii = 1;
            else
                iii = findstr(filenamepp,calib_name);
            end;       
            
            loc_ext = findstr(filenamepp,format_image);
            string_num = filenamepp(length_name+1:loc_ext - 2);
            
            if isempty(str2num(string_num)),
                iii = [];
            end;
            
            
            if ~isempty(iii),
                if (iii(1) ~= 1),
                    iii = [];
                end;
            end;
            
            
            
            if ~isempty(iii) & ~isempty(loc_ext),
                
                Nima_valid = Nima_valid + 1;
                ind_valid = [ind_valid pp];
                loc_extension = [loc_extension loc_ext(1)];
                
            end;
            
        end;
        
        if (Nima_valid==0),
            
            fprintf(1,'No image found. File format may be wrong.\n');
            
        else
            
            
            % Get all the string numbers:
            
            string_length = zeros(1,Nima_valid);
            indices =  zeros(1,Nima_valid);
            
            
            for ppp = 1:Nima_valid,
                
                name = l(ind_valid(ppp)).name;
                string_num = name(length_name+1:loc_extension(ppp) - 2);
                string_length(ppp) = size(string_num,2);
                indices(ppp) = str2num(string_num);
                
            end;
            
            % Number of images...
            first_num = min(indices);
            n_ima = max(indices) - first_num + 1;
            
            if min(string_length) == max(string_length),
                
                N_slots = min(string_length);
                type_numbering = 1;
                
            else
                
                N_slots = 1;
                type_numbering = 0;
                
            end;
            
            image_numbers = first_num:n_ima-1+first_num;
            
            %%% By default, all the images are active for calibration:
            
            active_images = ones(1,n_ima);
            
            
            
        end;
        
    else
        
        % Get all the string numbers:
        
        string_length = zeros(1,Nima_valid);
        indices =  zeros(1,Nima_valid);
        
        
        for ppp = 1:Nima_valid,
            
            name = l(ind_valid(ppp)).name;
            string_num = name(length_name+1:loc_extension(ppp) - 2);
            string_length(ppp) = size(string_num,2);
            indices(ppp) = str2num(string_num);
            
        end;
        
        % Number of images...
        first_num = min(indices);
        n_ima = max(indices) - first_num + 1;
        
        if min(string_length) == max(string_length),
            
            N_slots = min(string_length);
            type_numbering = 1;
            
        else
            
            N_slots = 1;
            type_numbering = 0;
            
        end;
        
        image_numbers = first_num:n_ima-1+first_num;
        
        %%% By default, all the images are active for calibration:
        
        active_images = ones(1,n_ima);
        
    end;
    
else
    
    fprintf(1,'No image found. Basename may be wrong.\n');
    
end;

