single_pkt() {
	f="$1"
	fbase=$(basename "$f")
	awk -vfname="$fbase" '

	function rmspace(s) {
		tmp_s = s
		gsub(" ", "", tmp_s)
		return tmp_s
	}

	function get_chain(s) {
		return rmspace(substr(s, 22, 1))
	}

	function get_resname(s) {
		return rmspace(substr(s, 18, 4))
	}

	function get_resseq(s) {
		return rmspace(substr(s, 23, 4))
	}

	function make_id(s) {
		v=get_chain($0)"_"get_resseq($0)"_"get_resname($0)
		return v
	}

	/^ATOM/ {
		id=make_id($0)
		if (!(id in ids)) {
			n = n + 1
			ids[id] = id
			order[n] = id
		}
	}

	END {
		printf fname"\t"n"\t"
		for (i = 1; i <= n; i++) {
			ord = order[i]
			if (i > 1) {
				printf ";"
			}
			printf ids[ord]
		}
		printf "\n"
	}

	' "$f"
}


echo -e "file\tnres\tresname"
for f in ./*pdb; do
	single_pkt "$f"
done
