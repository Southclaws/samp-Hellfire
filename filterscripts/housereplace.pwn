#include <a_samp>
#include <sscanf2>

public OnFilterScriptInit()
{
    new
        line[128],
        File:file;
    file = fopen("DATA\\index.ini", io_read);
    if (file)
    {
        new
            File:LS,
            File:SF,
            File:LV;
        LS = fopen("Maps/Houses/LS.txt", io_write);
        SF = fopen("Maps/Houses/SF.txt", io_write);
        LV = fopen("Maps/Houses/LV.txt", io_write);
        while (fread(file, line))
        {
            new
                File:ipl;
            strdel(line, strlen(line) - 2, strlen(line));
            ipl = fopen(line, io_read);
            if (ipl)
            {
                new
                    model,
                    Float:px,
                    Float:py,
                    Float:pz,
                    Float:rx,
                    Float:ry,
                    Float:rz,
                    Float:qx,
                    Float:qy,
                    Float:qz,
                    Float:qw;
                while (fread(ipl, line))
                {
                    if (sscanf(line, "p<,>i{s[32]i}fffffff{i}", model, px, py, pz, qx, qy, qz, qw))
                    {
                        continue;
                    }
                    model = GetSAMP03EModel(model);
                    if (model)
                    {
                        // Los Santos
                        if (19505 <= model <= 19511)
                        {
                            QuatToEulerZXY(qx, qy, qz, qw, rx, ry, rz);
                            AddObject(model, px, py, pz, rx, ry, rz, LS);
                            continue;
                        }
                        // San Fierro
                        if (19489 <= model <= 19495)
                        {
                            QuatToEulerZXY(qx, qy, qz, qw, rx, ry, rz);
                            AddObject(model, px, py, pz, rx, ry, rz, SF);
                            continue;
                        }
                        // Las Venturas
                        if (19497 <= model <= 19503)
                        {
                            QuatToEulerZXY(qx, qy, qz, qw, rx, ry, rz);
                            AddObject(model, px, py, pz, rx, ry, rz, LV);
                            continue;
                        }
                    }
                }
                fclose(ipl);
            }
        }
        fclose(file);
        fclose(LS);
        fclose(LV);
        fclose(SF);
    }
}

new gDoors[5]=
{
	1491,
	1492,
	1494,
	1499,
	1502
};

AddObject(model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, File:handle)
{
    new
        str[256];

    format(str, 256, "CreateObject(%d, %f, %f, %f, %f, %f, %f);\r\nCreateObject(%d, %f, %f, %f, %f, %f, %f);\r\n", model, x, y, z, rx, ry, rz, model + 1, x, y, z, rx, ry, rz);
    fwrite(handle, str);
    
    
    // LOS SANTOS
    if(model == 19509)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -1.00, 3.36, -2.13, 0.00, 0.00, 0.0, handle);
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -0.24, -5.79, -2.81, 0.00, 0.00, 0.0, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 2.56, 3.35, -0.47, 0.00, 0.00, 90.0, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -2.71, 3.34, -0.47, 0.00, 0.00, 90.0, handle);
    }
    if(model == 19507)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -5.03, 0.41, -2.55,   0.00, 0.00, 90.00, handle); // doors
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 6.36, 2.53, -2.54,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -3.92, 6.52, -1.03,   0.00, 0.00, 90.00, handle); // windows
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -0.79, 6.52, -1.03,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 1.99, 6.52, -1.03,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 4.99, 6.52, -1.03,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.41, -1.89, -0.92,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.41, -3.89, -0.92,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -2.80, -5.95, -0.99,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -5.08, 3.59, -0.91,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -5.08, -3.92, -0.91,   0.00, 0.00, 0.00, handle);
    }
    if(model == 19505)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 7.71, -4.28, -2.14,   0.00, 0.00, 90.00, handle); // doors
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -6.04, -0.31, -2.14,   0.00, 0.00, 270.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.76, 3.93, -0.52,   0.00, 0.00, 0.00, handle); // windows
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.76, 1.70, -0.52,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.14, 2.20, -0.72,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.14, 4.44, -0.72,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -3.33, 5.68, -0.50,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -4.57, -6.23, -0.46,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -0.95, -6.23, -0.46,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 2.72, -6.23, -0.46,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.91, -6.23, -0.46,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.14, -3.44, -0.44,   0.00, 0.00, 0.00, handle);
    }
    if(model == 19511)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -1.12, -5.35, -2.05,   0.00, 0.00, 90.00, handle); // doors
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 2.65, 5.93, -1.96,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 1.27, 5.96, -0.26,   0.00, 0.00, 90.00, handle); // windows
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -2.13, 5.96, -0.26,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.16, 3.32, -0.40,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.16, -1.80, -0.40,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.16, 0.65, -0.40,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 1.19, -3.36, -0.57,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -3.03, -5.92, -0.55,   0.00, 0.00, 90.00, handle);
    }
    
    // SAN FIERRO
    if(model == 19491)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -3.19, 1.96, -4.94,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 6.14, -2.76, -4.78,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 0.34, -3.40, -2.13,   0.00, 0.00, 270.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.05, -1.76, -3.28,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.05, 0.47, -3.28,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.47, 3.83, -3.05,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.45, 1.60, -3.05,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.40, 0.33, -3.05,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.44, 1.56, -0.54,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.44, 3.74, -0.54,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.44, -1.26, -0.54,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.06, 1.07, -0.42,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.06, -1.16, -0.42,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.06, 3.31, -0.42,   0.00, 0.00, 0.00, handle);
    }
    if(model == 19489)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -6.66, 1.01, -0.42,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 1.36, -4.99, -0.48,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -5.13, -1.89, 1.17,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.65, 3.72, 0.46,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.65, 2.34, 0.46,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.66, 2.39, 1.50,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.65, 3.84, 1.50,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.66, 2.09, 1.12,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.66, 3.69, 1.12,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.10, -0.10, 1.04,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.12, -2.28, 1.04,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.72, -1.81, -1.61,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.70, 0.30, -1.61,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.68, 3.75, -1.61,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.69, 1.52, -1.61,   0.00, 0.00, 0.00, handle);
    }
    if(model == 19495)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 5.68, -4.41, -4.33,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 3.30, -0.23, -4.66,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -1.95, -3.92, -4.50,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.00, 3.41, -2.82,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.00, 1.17, -2.82,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.00, -1.56, -2.84,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.00, 3.34, -0.07,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.00, 1.10, -0.07,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 6.00, -3.05, -0.02,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.00, -0.48, 0.23,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.00, -2.72, 0.23,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -4.84, 3.00, -0.83,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -4.85, 3.00, 0.46,   0.00, 0.00, 0.00, handle);
    }
    if(model == 19493)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -3.05, -3.72, -4.34,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 5.34, -3.52, -4.67,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.70, -0.60, -2.89,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.68, 1.07, -3.25,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.68, 3.23, -3.15,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -4.62, -0.58, -2.96,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.70, -2.29, -0.27,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.67, 2.95, -0.27,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 5.67, 0.71, -0.27,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -5.19, -1.93, -0.19,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -5.15, 3.03, -0.29,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -5.15, 0.80, -0.29,   0.00, 0.00, 0.00, handle);
    }
    
    // LAS VENTURAS
    if(model == 19497)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -1.62, -0.99, -1.73,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 5.56, -5.33, -1.70,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 9.45, -8.08, -1.66,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -4.46, 4.24, 0.30,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -4.46, 8.49, 0.30,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 9.60, 8.99, 0.46,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 9.60, 0.32, -0.01,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -1.75, -3.93, 0.01,   0.00, 0.00, 0.00, handle);
    }
    if(model == 19501)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -6.91, -3.63, -3.10,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(1494, x, y, z, rx, ry, rz, -5.88, 8.85, -2.96,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(1494, x, y, z, rx, ry, rz, -2.88, 8.85, -2.96,   0.00, 0.00, 180.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -7.30, 0.90, -1.40,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -7.30, -1.34, -1.52,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -7.30, 3.22, -1.38,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -7.30, 5.46, -1.38,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.07, -2.27, -1.32,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.07, -0.03, -1.32,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.07, -4.51, -1.32,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.07, 5.00, -1.41,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.07, 2.76, -1.41,   0.00, 0.00, 0.00, handle);
    }
    if(model == 19499)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -5.65, -2.95, -3.36,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(1494, x, y, z, rx, ry, rz, 2.42, 6.30, -3.39,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(1494, x, y, z, rx, ry, rz, 5.44, 6.30, -3.39,   0.00, 0.00, 180.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.07, -1.00, -1.78,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.07, 1.24, -1.78,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -6.07, 3.48, -1.78,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.03, 1.92, -1.73,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.03, 4.16, -1.73,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.04, -4.87, -1.73,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.04, -2.64, -1.73,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, 7.04, -7.11, -1.73,   0.00, 0.00, 0.00, handle);
    }
    if(model == 19503)
    {
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, -1.26, -1.87, -2.22,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(gDoors[random(sizeof(gDoors))], x, y, z, rx, ry, rz, 3.82, -1.78, -2.15,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19363, x, y, z, rx, ry, rz, 1.85, -1.88, -1.50,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19325, x, y, z, rx, ry, rz, -7.78, -9.10, -1.52,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19466, x, y, z, rx, ry, rz, -12.07, -9.10, -0.85,   90.00, 0.00, 90.00, handle);
		SaveOffsetObj(19325, x, y, z, rx, ry, rz, -12.94, -5.09, -1.37,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19325, x, y, z, rx, ry, rz, -12.94, 0.36, -1.29,   0.00, 0.00, 0.00, handle);
		SaveOffsetObj(19325, x, y, z, rx, ry, rz, -8.32, 8.00, -0.96,   0.00, 0.00, 90.00, handle);
		SaveOffsetObj(19325, x, y, z, rx, ry, rz, 0.81, 8.00, -1.73,   0.00, 0.00, 90.00, handle);
    }
}

SaveOffsetObj(
	model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz,
    Float:object_px, Float:object_py, Float:object_pz, Float:object_rx, Float:object_ry, Float:object_rz,
	File:handle)
{
	new
        str[256],
	    Float:new_x,
	    Float:new_y,
	    Float:new_z;

	GetAttachedObjectPos(
		x, y, z, rx, ry, rz,
		object_px, object_py, object_pz,
		new_x, new_y, new_z);


	format(str, 256, "CreateObject(%d, %f, %f, %f, %f, %f, %f);\r\n",
	    model, new_x, new_y, new_z, object_rx+rx, object_ry+ry, object_rz+rz);

    fwrite(handle, str);


}
stock GetAttachedObjectPos(
    Float:object_px, Float:object_py, Float:object_pz, Float:object_rx, Float:object_ry, Float:object_rz,
	Float:offset_x, Float:offset_y, Float:offset_z,
	&Float:x, &Float:y, &Float:z)
{
    new
		Float:cos_x = floatcos(object_rx, degrees),
        Float:cos_y = floatcos(object_ry, degrees),
        Float:cos_z = floatcos(object_rz, degrees),
        Float:sin_x = floatsin(object_rx, degrees),
        Float:sin_y = floatsin(object_ry, degrees),
        Float:sin_z = floatsin(object_rz, degrees);

    x = object_px + offset_x * cos_y * cos_z - offset_x * sin_x * sin_y * sin_z - offset_y * cos_x * sin_z + offset_z * sin_y * cos_z + offset_z * sin_x * cos_y * sin_z;
    y = object_py + offset_x * cos_y * sin_z + offset_x * sin_x * sin_y * cos_z + offset_y * cos_x * cos_z + offset_z * sin_y * sin_z - offset_z * sin_x * cos_y * cos_z;
    z = object_pz - offset_x * cos_x * sin_y + offset_y * sin_x + offset_z * cos_x * cos_y;
}

QuatToEulerZXY(Float:quat_x, Float:quat_y, Float:quat_z, Float:quat_w, &Float:x, &Float:y, &Float:z)
{
    x = -asin(2 * ((quat_x * quat_z) + (quat_w * quat_y)));
    y = atan2(2 * ((quat_y * quat_z) + (quat_w * quat_x)), (quat_w * quat_w) - (quat_x * quat_x) - (quat_y * quat_y) + (quat_z * quat_z));
    z = -atan2(2 * ((quat_x * quat_y) + (quat_w * quat_z)), (quat_w * quat_w) + (quat_x * quat_x) - (quat_y * quat_y) - (quat_z * quat_z));
    return 1;
}

GetSAMP03EModel(model)
{
    // Los Santos
    if (model == 3592 || model == 3563 || model == 5664 || model == 3591) return 19509;
    if (model == 3647) return 19507;
    if (model == 3706 || model == 3654 || model == 5672) return 19505;
    if (model == 3720) return 19511;
    // San Fierro
    if (model == 3832 || model == 3840) return 19491;
    if (model == 3835 || model == 3833) return 19489;
    if (model == 3838 || model == 3848) return 19495;
    if (model == 3841 || model == 3836) return 19493;
    // Las Venturas
    if (model == 3536) return 19497;
    if (model == 3546) return 19501;
    if (model == 3547) return 19499;
    if (model == 3548) return 19503;
    return 0;
}


