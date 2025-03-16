function [varargout] = tide_gauge_info(sid)
% bodc.tide_gauge_info - provides ordnance datum conversion, latitude and longitude, and the full site name for BODC tide gauge sites
%
% Inputs:
%   sid - site identifier: either BODC three letter sitecode or full site name (case insensitive) (e.g., "abe" or "aberdeen")
%
% Outputs (in order):
%   1st - latitude and longitude of tide gauge site in 2x1 array
%   2nd - full site name as string (e.g., "Aberdeen")
%   3rd - 3 letter site code
%   4th - datum conversion number from chart datum to ordnance datum (to be added to the water levels)

% Luke Jenkins Feb 2023
% L.Jenkins@soton.ac.uk

% can you believe I typed all this out?! what a hack
arguments
    sid string {mustBeTextScalar}
end

if any(strcmpi(sid, ["dov", "dover"]) == 1)
    full_sid = "Dover"; datum = -3.67; latlon = [51.114389 1.322528]; sc = "DOV";
elseif any(strcmpi(sid, ["har", "harwich"]) == 1)
    full_sid = "Harwich"; datum = -2.02; latlon = [51.948000 1.292056]; sc = "HAR";
elseif any(strcmpi(sid, ["hey", "heysham"]) == 1)
    full_sid = "Heysham"; datum = -4.90; latlon = [54.031833 -2.920250]; sc = "HEY";
elseif any(strcmpi(sid, ["hin", "hinkley", "hinkley point", "hinkley_point", "hinkleypoint"]) == 1)
    full_sid = "Hinkley Point"; datum = -5.90; latlon = [51.215250 -3.134472]; sc = "HIN" ;
elseif any(strcmpi(sid, ["low", "lowestoft"]) == 1)
    full_sid = "Lowestoft"; datum = -1.50; latlon = [52.473083 1.750250]; sc = "LOW";
elseif any(strcmpi(sid, ["nha", "newhaven"]) == 1)
    full_sid = "Newhaven"; datum = -3.52; latlon = [50.781778 0.057028]; sc = "NHA";
elseif any(strcmpi(sid, ["abe", "aberdeen"]) == 1)
    full_sid = "Aberdeen"; datum = -2.25; latlon = [57.144028 -2.080222]; sc = "ABE";
elseif any(strcmpi(sid, ["ptm", "portsmouth"]) == 1)
    full_sid = "Portsmouth"; datum = -2.73; latlon = [50.802194 -1.111250]; sc = "PTM";
elseif any(strcmpi(sid, ["avo", "avonmouth"]) == 1)
    full_sid = "Avonmouth"; datum = -6.50; latlon = [51.507750 -2.712750]; sc = "AVO";
elseif any(strcmpi(sid, ["bou", "bournemouth"]) == 1)
    full_sid = "Bournemouth"; datum = -1.40; latlon = [50.714333 -1.874861]; sc = "BOU";
elseif any(strcmpi(sid, ["ban", "bangor", "belfast"]) == 1)
    full_sid = "Bangor"; datum = -2.01; latlon = [54.664750 -5.669472]; sc = "BAN";
elseif any(strcmpi(sid, ["bar", "barmouth"]) == 1)
    full_sid = "Barmouth"; datum = -2.44; latlon = [52.719333 -4.045028]; sc = "BAR";
elseif any(strcmpi(sid, ["cro", "cromer"]) == 1)
    full_sid = "Cromer"; datum = -2.75; latlon = [52.934194 1.301639]; sc = "CRO";
elseif any(strcmpi(sid, ["dev", "devonport"]) == 1)
    full_sid = "Devonport"; datum = -3.22; latlon = [50.368389 -4.185250]; sc = "DEV";
elseif any(strcmpi(sid, ["mum", "mumbles"]) == 1)
    full_sid = "Mumbles"; datum = -5.00; latlon = [51.570000 -3.975472]; sc = "MUM";
elseif any(strcmpi(sid, ["fis", "fishguard"]) == 1)
    full_sid = "Fishguard"; datum = -2.44; latlon = [52.013222 -4.983750]; sc = "FIS";
elseif any(strcmpi(sid, ["ilf", "ilfracombe"]) == 1)
    full_sid = "Ilfracombe"; datum = -4.80; latlon = [51.211139 -4.112389]; sc = "ILF";
elseif any(strcmpi(sid, ["hol", "holyhead"]) == 1)
    full_sid = "Holyhead"; datum = -3.05; latlon = [53.313944 -4.620417]; sc = "HOL";
elseif any(strcmpi(sid, ["imm", "immingham"]) == 1)
    full_sid = "Immingham"; datum = -3.90; latlon = [53.630417 -0.187528]; sc = "IMM";
elseif any(strcmpi(sid, ["kin", "kinlochbervie", "kinloch"]) == 1)
    full_sid = "Kinlochbervie"; datum = -2.50; latlon = [58.456694 -5.050222]; sc = "KIN";
elseif any(strcmpi(sid, ["lei", "leith"]) == 1)
    full_sid = "Leith"; datum = -2.90; latlon = [55.989833 -3.181694]; sc = "LEI";
elseif any(strcmpi(sid, ["ler", "lerwick"]) == 1)
    full_sid = "Lerwick"; datum = -1.22; latlon = [60.154028 -1.140306]; sc = "LER";
elseif any(strcmpi(sid, ["liv", "liverpool", "hilbreisland", "hilbre", "hilbre island"]) == 1)
    full_sid = "Liverpool"; datum = -4.93; latlon = [53.449694 -3.018139]; sc = "LIV";
elseif any(strcmpi(sid, ["lla", "llandudno"]) == 1)
    full_sid = "Llandudno"; datum = -3.85; latlon = [53.331667 -3.825222]; sc = "LLA";
elseif any(strcmpi(sid, ["mha", "milford haven", "milford_haven", "milfordhaven"]) == 1)
    full_sid = "Milford Haven"; datum = -3.71; latlon = [51.707389 -5.051778]; sc = "MHA";
elseif any(strcmpi(sid, ["new", "newlyn"]) == 1)
    full_sid = "Newlyn"; datum = -3.05; latlon = [50.103000 -5.542750]; sc = "NEW";
elseif any(strcmpi(sid, ["npo", "newport"]) == 1)
    full_sid = "Newport"; datum = -5.81; latlon = [51.550000 -2.987444]; sc = "NPO";
elseif any(strcmpi(sid, ["nsh", "north shields", "northshields", "shields"]) == 1)
    full_sid = "North Shields"; datum = -2.60; latlon = [55.007444 -1.439778]; sc = "NSH";
elseif any(strcmpi(sid, ["she", "sheerness"]) == 1)
    full_sid = "Sheerness"; datum = -2.90; latlon = [51.445639 0.743361]; sc = "SHE";
elseif any(strcmpi(sid, ["tob", "tobermory"]) == 1)
    full_sid = "Tobermory"; datum = -2.39; latlon = [56.623111 -6.064222]; sc = "TOB";
elseif any(strcmpi(sid, ["ull", "ullapool"]) == 1)
    full_sid = "Ullapool"; datum = -2.75; latlon = [57.895250 -5.158056]; sc = "ULL";
elseif any(strcmpi(sid, ["wey", "Weymouth"]) == 1)
    full_sid = "Weymouth"; datum = -0.93; latlon = [50.608500 -2.447944]; sc = "WEY";
elseif any(strcmpi(sid, ["whi", "Whitby"]) == 1)
    full_sid = "Whitby"; datum = -3.00; latlon = [54.490000 -0.614694]; sc = "WHI";
elseif any(strcmpi(sid, ["wic", "Wick"]) == 1)
    full_sid = "Wick"; datum = -1.71; latlon = [58.440972 -3.086389]; sc = "WIC";
elseif any(strcmpi(sid, ["wor", "Workington"]) == 1)
    full_sid = "Workington"; datum = -4.20; latlon = [54.650722 -3.567167]; sc = "WOR";
elseif any(strcmpi(sid, ["sto", "Stornoway"]) == 1)
    full_sid = "Stornoway"; datum = -2.71; latlon = [58.207722 -6.388889]; sc = "STO";
elseif any(strcmpi(sid, ["stm", "St. Marys", "Marys", "St. Mary's", "Mary's", "StMarys"]) == 1)
    full_sid = "St. Mary's"; datum = -2.91; latlon = [49.917833 -6.317139]; sc = "STM";
elseif any(strcmpi(sid, ["jer", "St. Helier", "Helier", "jersey"]) == 1)
    full_sid = "St. Helier"; datum = -5.88; latlon = [49.183333 -2.116667]; sc = "JER";
elseif any(strcmpi(sid, ["isl", "Port Ellen", "ellen", "portellen", "islay"]) == 1)
    full_sid = "Port Ellen"; datum = -0.19; latlon = [55.627583 -6.189917]; sc = "ISL";
elseif any(strcmpi(sid, ["iom", "Port Erin", "erin", "porterin", "isle of man", "isle_of_man", "man"]) == 1)
    full_sid = "Port Erin"; datum = -2.75; latlon = [54.085222 -4.768056]; sc = "IOM";
elseif any(strcmpi(sid, ["por", "Portpatrick"]) == 1)
    full_sid = "Portpatrick"; datum = -1.80; latlon = [54.842556 -5.120028]; sc = "POR";
elseif any(strcmpi(sid, ["pru", "Portrush"]) == 1)
    full_sid = "Portrush"; datum = -1.24; latlon = [55.206778 -6.656833]; sc = "PRU";
elseif any(strcmpi(sid, ["fel", "Felixstowe", "felixstowepier", "felixstowe pier"]) == 1)
    full_sid = "Felixstowe"; datum = -1.95; latlon = [51.956750 1.348389]; sc = "FEL";
elseif any(strcmpi(sid, ["mor", "Moray Firth", "moray", "firth", "morayfirth"]) == 1)
    full_sid = "Moray Firth"; datum = -2.22; latlon = [57.599167 -4.002222]; sc = "MOR";
elseif any(strcmpi(sid, ["ptb", "Portbury"]) == 1)
    full_sid = "Portbury"; datum = -6.50; latlon = [51.500000 -2.728472]; sc = "PTB";
elseif any(strcmpi(sid, ["mil", "Millport"]) == 1)
    full_sid = "Millport"; datum = -1.62; latlon = [55.749806 -4.906333]; sc = "MIL";
elseif any(strcmpi(sid, ["belfast"]) == 1)
    full_sid = "Belfast"; datum = nan; latlon = [nan nan]; sc = nan;
elseif any(strcmpi(sid, ["exmouth"]) == 1)
    full_sid = "Exmouth"; datum = nan; latlon = [nan nan]; sc = nan;
elseif any(strcmpi(sid, ["padstow"]) == 1)
    full_sid = "Padstow"; datum = nan; latlon = [nan nan]; sc = nan;
end

varargout = cell(nargout, 1);
if exist("full_sid", "var") ~= 1
    for k = 1:nargout
        varargout{k} = false;
    end
else
    out = {latlon, full_sid, sc, datum};
    for k = 1:nargout
        varargout{k} = out{k};
    end
end

% fini