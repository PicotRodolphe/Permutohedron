let n = 3


let rec affiche l = 
	match l with
	| a::b -> Printf.printf "%d" a ; affiche b
	| [] -> Printf.printf "[]\n"

let fact n = 
	let rec factorielle x acc =
		match x with
		| 0 -> acc
		| a -> factorielle (x-1) (acc*a)
	in
	factorielle n 1

let count = fact n

(*
	Mahonian fonction

	M(0, 0) = 1
	M(0, c) = 0 for c <> 0
	M(r, c) = Σ(k=0 -> r) M(r - 1, c-k )

*)

let rec mahonian r c =
	match r, c with
	| 0, 0 -> 1
	| 0, col when c <> 0 -> 0
	| lig, col -> let res = ref 0 in 

	(for i = 0 to lig do 
		res := !res + mahonian (lig - 1 ) ( col - i )
	done);

	!res
	

let matrice = Hashtbl.create 1

let rec construction r niv = 

		if r = 0 then 
			Hashtbl.add matrice (r,niv) (1,1::[])

		else if r >= ((niv-1)*(niv))/2 + 1 && niv > 0 then 

			Hashtbl.add matrice (r,niv) (0,[]) 
		
		else

			let rec col acc c tot=
				let ligne = r-c in 

				if ligne >= 0 then (* on remonte la colonne precedente .....*)

					try
						let (valeur,_) = Hashtbl.find matrice (ligne, niv-1) in 

						if tot = mahonian niv r then (* ... mais on s'arrete quand on a atteind le nombre de mahonian c'est à dire min(n ,k+1)*)
							Hashtbl.add matrice (r,niv) (tot,List.rev_append acc []) 
						
						else 
							col (valeur::acc) (c+1) (tot+valeur)

					with Not_found -> construction ligne (niv-1) ; col acc c tot
				
				else
					Hashtbl.add matrice (r,niv) (tot,List.rev_append acc [])

		in 

		col [] 0 0


let parcourt dec i =


	let rec parc d reste c = 
		match d with
		| a::b -> if a > reste then (reste, c) else parc b (reste-a) (c+1)
		| [] -> (0,0) (*n'arrive jamais*)
	in

	parc dec i 0



let lehmer rang index = 


	let rec rec_lehmer r i nbr acc=

		if nbr = 1 && r = 0 then (0::acc) (*on aurait pu ecrire (Hashtbl.find matrice (r,nbr) )::acc*)
		else
			try 
				let (_,decoupage) = Hashtbl.find matrice (r, nbr) in 
				let (new_index, res) = parcourt decoupage i in 
				rec_lehmer (r-res) new_index (nbr-1) (res::acc)

			with Not_found -> construction r nbr ; rec_lehmer r i nbr acc

	in 

	rec_lehmer rang index n []

let permut_to_lehmer code_lehmer =

	let possibles = (*liste les nombres allant de 1 à n*)
		let rec construct i acc = 
			if i > 0 then 
				construct (i-1) (i::acc)
			else
				acc
		in
		construct n []
	in 

	let n_elem liste compteur =
		let rec n_e l c acc=
			match l with
			| a::b ->  if c=0 then (a,(List.rev_append acc b))  else n_e b (c-1) (a::acc) 
			| [] -> (0,[]) (*Ne doit pas arriver*)
		in
		
		n_e liste compteur []

	in 

	let rec trans lehm reste acc = 
		match lehm with
		| a::b -> let (nieme, r) = n_elem reste a in trans b r (nieme::acc)
		| [] -> List.rev_append acc []
	in

	trans code_lehmer possibles []

let debug () = 
	Hashtbl.iter (fun (x,y) (tot, liste) -> Printf.printf "x %d y %d tot %d liste " x y tot ; 
											affiche liste ;
											Printf.printf "\n" ) matrice 

let unrank rang index = 

	let leh = List.rev_append (lehmer rang index) [] in 
	let permut = permut_to_lehmer leh  in (*la permutation est sous forme de liste *)
	affiche permut 

let () =
	Hashtbl.add matrice (0,1) (1,(1::[]));
	unrank 3 0