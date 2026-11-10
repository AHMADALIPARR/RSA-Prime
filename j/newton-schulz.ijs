NB. SPDX-License-Identifier: AGPL-3.0-only
NB. This program is free software: you can redistribute it and/or modify
NB. it under the terms of the GNU Affero General Public License as published by
NB. the Free Software Foundation, version 3.
NB. See the LICENSE file.

NB. <<<< init  
A =: 2 2 $ 4 1 2 3  
alpha =: 0.05  
T0 =: alpha * |: A  
I =: = i. {.$A  
  
NB. predicate Hop: F(Tn) -> Tn+1  
Hop =: 3 : 'y +/ . * (2 * I) - A +/ . * y'  
  
NB. recurse (Limit n=5)  
T_final =: Hop^:5 T0  
NB. back init ———>>>>>>  
