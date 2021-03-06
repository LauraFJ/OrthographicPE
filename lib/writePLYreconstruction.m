function writePLYreconstruction(file_name,CalM,R_t,Reconst,Color)
%WRITEPLYRECONSTRUCTION creates a ply file for the 3D reconstruction 
% 
%  Input arguments:
%  file_name  - string containing the name of the file
%  CalM       - 3Mx3 containing the M calibration 3x3 matrices for 
%               each camera concatenated.
%  R_t        - 3Mx4 matrix containing the global rotation and translation
%               [R,t] for each camera concatenated.
%  Reconst    - 3xN matrix containing the N 3D points.
%  Color      - 3xN matrix containing the color of each 3D point (optional).

% Copyright (c) 2017 Laura F. Julia <laura.fernandez-julia@enpc.fr>
% All rights reserved.
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


N=size(Reconst,2);
M=size(R_t,1)/3;

col=nargin>4;

file = fopen(file_name, 'wt');
fprintf(file,'ply\nformat ascii 1.0\nelement vertex %d\n', N+5*M);
fprintf(file,'property float x\nproperty float y\nproperty float z\n');
fprintf(file,'property uchar red\nproperty uchar green\nproperty uchar blue\n');
fprintf(file,'element edge %d\nproperty int vertex1\nproperty int vertex2\n',8*M);
fprintf(file,'property uchar red\nproperty uchar green\nproperty uchar blue\n');
fprintf(file,'end_header\n');

% Reconstruction Points
for n=1:N
    fprintf(file,'%f %f %f ',Reconst(1,n),Reconst(2,n),Reconst(3,n));
    if col
        fprintf(file,'%d %d %d\n',Color(1,n),Color(2,n),Color(3,n));
    else
        fprintf(file,'255 255 255\n');
    end
end

scale=1/100000;
% Camera Points and vertices
for m=1:M
    O=-R_t((m-1)*3+(1:3),1:3)'*R_t((m-1)*3+(1:3),4);
    fprintf(file,'%f %f %f 0 255 0\n',O(1),O(2),O(3));
    frame=[CalM((m-1)*3+(1:2),3);CalM((m-1)*3+1,1)]*scale;
    for i=1:4
        P=R_t((m-1)*3+(1:3),1:3)'*frame+O;
        fprintf(file,'%f %f %f 0 255 0\n',P(1),P(2),P(3));
        frame(1)=-frame(1);
        if i==2
            frame(2)=-frame(2);
        end
    end
end
for m=1:M
    ind=N+(m-1)*5;
    for i=1:4
        fprintf(file,'%d %d 0 255 0\n',ind, ind+i);
    end
    fprintf(file,'%d %d 0 255 0\n',ind+1, ind+2);
    fprintf(file,'%d %d 0 255 0\n',ind+2, ind+4);
    fprintf(file,'%d %d 0 255 0\n',ind+4, ind+3);
    fprintf(file,'%d %d 0 255 0\n',ind+3, ind+1);
end

fclose(file);







