function uuid = struct2uuid(structure)
% Given a dictionary structure, returns a hash string as UUID

uuid = hashlib.md5hex(structure);

end

