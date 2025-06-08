for _, obj in pairs(workspace:GetDescendants()) do
   if obj:IsA("BasePart") and string.match(obj.Name:lower(), "drone") then --- TROQUE A STRING PELO NOME QUE DESEJA PROCURAR
      print("Possível Objeto Encontrado", obj:GetFullName(), obj.Position)
   end
end