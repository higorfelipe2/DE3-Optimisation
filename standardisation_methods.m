%(----------------------IGNORE
%attempts to standardise the data, all resulted in less accurate model with
%greater variation (orders of magnitude different) from predicted to actual data

%method1 - per vector standardisation (ignore, incorrect)
%meanData = mean(data);
%stdData = std(data);
%data(:,1) = (hT-meanData(1))/stdData(1);
%data(:,2) = (lT-meanData(2))/stdData(2);
%data(:,3) = (rT-meanData(3))/stdData(3);
%data(:,4) = (m-meanData(4))/stdData(4);
%data(:,5) = (stress-meanData(5))/stdData(5);
%data(:,6) = (disp-meanData(6))/stdData(6);

%method2 - whole dataset standardisation (ignore, incorrect)
%meanAllData = mean2(data);
%stdAllData = std2(data);
%data = (data - meanAllData)/stdAllData

%method 3
%maxData = max(data);
%minData = min(data);
%data(:,1) = hT/(maxData(1)-minData(1))
%data(:,2) = lT/(maxData(2)-minData(2))
%data(:,3) = rT/(maxData(3)-minData(3))
%data(:,4) = mass/(maxData(4)-minData(4))
%data(:,5) = stress/(maxData(5)-minData(5))
%data(:,6) = disp/(maxData(6)-minData(6))
%-----------------END IGNORE)