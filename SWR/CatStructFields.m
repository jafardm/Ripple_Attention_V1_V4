function S = CatStructFields(S, T, dim)
fields = fieldnames(S);
for k = 1:numel(fields)
  aField     = fields{k}; % EDIT: changed to {}
  S.(aField) = cat(dim, S.(aField), T.(aField));
end
