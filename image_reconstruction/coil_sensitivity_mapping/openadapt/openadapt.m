function csm = openadapt(img)
%%Simple wrapper around the openadapt function that does the permute
%%operations. Real algorithm is in openadapt_algo

img=permute(img,[4 1 2 3]);
[~,csm]=openadapt_algo(img);
csm=permute(csm,[2 3 4 1]);

% END
end
