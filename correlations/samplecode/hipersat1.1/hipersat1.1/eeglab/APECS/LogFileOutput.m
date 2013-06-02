function LogFileOutput(fileName, logFile, displayLog);

if displayLog

	disp(logFile);
	
end

[m n] = size(logFile);

fid = fopen([fileName '.txt'],  'w', 'b');

for i = 1:m

	fprintf(fid, '%s\n', logFile(i,:));

end

fclose(fid);
