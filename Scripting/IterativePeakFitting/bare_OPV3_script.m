ids = [2,3,12,13,14,15,16];
lib = build_library();

N = length(ids);

fit_peaks = zeros(N,11);

for i = 1:N
    disp([i N]);
    T = load_library_entry(lib,ids(i));
    
    fit_peaks(i,:) = iteratative_gaussian_fit(T);
end