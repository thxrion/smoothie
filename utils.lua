function arrayForeach(array, callback)
      for i = 1, #array do
            local callResult = callback(array[i], i)

            if callResult then
                  return callResult
            end
      end
end

function arrayFind(haystack, needle)
      for i = 1, #haystack do
            if haystack[i] == needle then
                  return true
            end
      end
      
      return false
end