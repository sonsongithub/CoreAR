function [] = write_image(I, kk , calib_name , format_image , type_numbering , image_numbers , N_slots),

if format_image(1) == 'j',
    format_image = 'bmp';
end;


if ~type_numbering,   
    number_ext =  num2str(image_numbers(kk));
else
    number_ext = sprintf(['%.' num2str(N_slots) 'd'],image_numbers(kk));
end;

ima_name2 = [calib_name  number_ext '.' format_image];

fprintf(1,['Saving image under ' ima_name2 '...\n']);

if format_image(1) == 'p',
    if format_image(2) == 'p',
        saveppm(ima_name2,uint8(round(I)));
    else
        savepgm(ima_name2,uint8(round(I)));
    end;
else
    if format_image(1) == 'r',
        writeras(ima_name2,round(I),gray(256));
    else
        imwrite(uint8(round(I)),gray(256),ima_name2,format_image);
    end;
end;
