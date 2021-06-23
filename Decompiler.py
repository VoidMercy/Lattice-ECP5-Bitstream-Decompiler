import json
import os

class Node:
	def __init__(self, name):
		self.name = name
		self.children = set()
		self.parents = set()
	def __str__(self):
		return self.name
	def __repr__(self):
		return "\"{}\"".format(self.name)

class Graph:
	def __init__(self, arcs):
		self.node_map = {}
		for arc in arcs:
			sink = arc.split("assign ")[1].split(" = ")[0]
			source = arc.split(" = ")[1].split(";")[0]

			if sink not in self.node_map:
				self.node_map[sink] = Node(sink)
			sink_node = self.node_map[sink]
			if source not in self.node_map:
				self.node_map[source] = Node(source)
			source_node = self.node_map[source]

			sink_node.parents.add(source)
			if len(sink_node.parents) > 1:
				print("Warning: multiple drivers sink:{}, sources:{}".format(sink, str(sink_node.parents)))
			source_node.children.add(sink)

	def find_top_ports(self):
		top_ports = set()
		# TODO: make better
		# all_nodes = self.find_all_nodes("JPAD") + self.find_all_nodes("G_") + self.find_all_nodes("JDI") + self.find_all_nodes("IOLOGIC")
		all_nodes = self.find_all_nodes("PLC2")
		seen_children = set()
		seen_parents = set()
		visited = set()
		for node in all_nodes:
			# Perform DFS on all PLC2 nodes, and any node that is either root or leaf that's not CIB or PLC2 will be a top level port
			top_input_ports = self.find_root(node)
			top_output_ports = self.find_leaf(node)
			for p in top_input_ports:
				if p in visited:
					continue
				visited.add(p)
				if "PLC2" not in p and not p.endswith("_EBR") and not ("CIB_" in p and p.endswith("HFIE0000")) and not ("CIB_" in p and p.endswith("HL7W0001")) and p != "1'b0":
					cur_reachable_children = self.find_all_reachable_children(p)
					if len(cur_reachable_children.intersection(seen_children)) == 0:
						top_ports.add("input wire {}".format(p))
						self.dfs_traverse_down(p, pr=True)
					else:
						print("Input Duplicate", p)
						# assert len(cur_reachable_children.intersection(seen_children)) == len(cur_reachable_children)
					seen_children |= cur_reachable_children
			for p in top_output_ports:
				if p in visited:
					continue
				visited.add(p)
				if "PLC2" not in p and not p.endswith("_EBR") and not ("CIB_" in p and p.endswith("HFIE0000")) and not ("CIB_" in p and p.endswith("HL7W0001")) and p != "1'b0":
					cur_reachable_parents = self.find_all_reachable_parent(p)
					if len(cur_reachable_parents.intersection(seen_parents)) == 0:
						top_ports.add("output wire {}".format(p))
						self.dfs_traverse_up(p, pr=True)
					else:
						print("Output Duplicate", p)
						# assert len(cur_reachable_parents.intersection(seen_parents)) == len(cur_reachable_parents)
					seen_parents |= cur_reachable_parents
		return list(top_ports)

	def find_all_reachable_parent(self, a):
		marked = set()
		stack = []
		stack.append((a, 0))
		while len(stack) > 0:
			current, depth = stack.pop()
			marked.add(current)
			for parent in self.node_map[current].parents:
				stack.append((parent, depth + 1))
		return marked

	def find_all_reachable_children(self, a):
		marked = set()
		stack = []
		stack.append((a, 0))
		while len(stack) > 0:
			current, depth = stack.pop()
			marked.add(current)
			for child in self.node_map[current].children:
				stack.append((child, depth + 1))
		return marked

	def find_leaf(self, node):
		ret = []
		stack = []
		stack.append((node, 0))
		while len(stack) > 0:
			current, depth = stack.pop()
			if len(self.node_map[current].children) == 0:
				ret.append(current)
			for child in self.node_map[current].children:
				stack.append((child, depth + 1))
		return ret

	def find_root(self, node):
		ret = []
		stack = []
		stack.append((node, 0))
		while len(stack) > 0:
			current, depth = stack.pop()
			if len(self.node_map[current].parents) == 0:
				ret.append(current)
			for parent in self.node_map[current].parents:
				stack.append((parent, depth + 1))
		return ret

	def find_all_nodes(self, match):
		nodes = []
		for i in self.node_map:
			if match in i:
				nodes.append(i)
		return nodes

	def dfs_traverse_down(self, node, pr=False):
		if pr:
			print("="*40)
			print("Traverse down {}".format(node))
			print("="*40)
		stack = []
		stack.append((node, 0))
		encounter = False
		while len(stack) > 0:
			current, depth = stack.pop()
			if "PLC2" in current:
				encounter = True
			if pr:
				print("Node {}, Depth {}".format(current, depth))
			for child in self.node_map[current].children:
				stack.append((child, depth + 1))
		return encounter
	def dfs_traverse_up(self, node, pr=False):
		if pr:
			print("="*40)
			print("Traverse up {}".format(node))
			print("="*40)
		stack = []
		stack.append((node, 0))
		encounter = False
		while len(stack) > 0:
			current, depth = stack.pop()
			if "PLC2" in current:
				encounter = True
			if pr:
				print("Node {}, Depth {}".format(current, depth))
			for parent in self.node_map[current].parents:
				stack.append((parent, depth + 1))
		return encounter

def signal_is_global(signal):
	global_whitelist = ["L", "G", "R"]
	if "_" not in signal:
		return False
	if signal[1] == "_" and signal[0] in global_whitelist:
		return True
	start_part = signal.split("_")[0]
	for i in range(0, len(start_part), 2):
		if start_part[i] not in ["N", "S", "E", "W"]:
			return False
		if start_part[i + 1] not in [str(i) for i in range(1, 10)]:
			return False
	return True

class Tile:
	def __init__(self, name, tile_map, global_ports, tilegrid):
		self.name = name
		self.row = int(name.split(":")[0].split("R")[1].split("C")[0])
		self.col = int(name.split(":")[0].split("R")[1].split("C")[1])
		self.type = name.split(":")[1]
		self.global_ports = global_ports
		self.tile_map = tile_map
		self.tilegrid = tilegrid

		self.internal_signals = set()
		self.internal_ports = set()

		tiledata_path = os.path.join(os.path.join("./prjtrellis-db/ECP5/tiledata/", self.type), "bits.db")
		self.bitsdb = open(tiledata_path, "r").read()

		self.fixed_conns = self.parse_fixed_conns_bitsdb() # (Source, Sink)
		self.arcs = [] # (Source, Sink)
		self.enums = {}
		self.words = {}

		# Add signals to list of internal ports and/or slice ports
		for conn in self.fixed_conns:
			if not signal_is_global(conn[0]):
				self.internal_signals.add(conn[0])
				if "_" in conn[0]:
					self.internal_ports.add(conn[0])
			else:
				self.global_ports.add(conn[0])
			if not signal_is_global(conn[1]):
				self.internal_signals.add(conn[1])
				if "_" in conn[1]:
					self.internal_ports.add(conn[1])
			else:
				self.global_ports.add(conn[1])

	def parse_fixed_conns_bitsdb(self):
		conns = []
		# Ignore DSP tiles' fixed conns
		if "DSP" in self.type and "CIB" not in self.type:
			return conns
		for line in self.bitsdb.split("\n"):
			if line.startswith(".fixed_conn"):
				temp = tuple(line.split()[1:])
				# Ignore CIBTEST signals
				if self.is_not_blacklisted(temp[0], temp[1]):
					conns.append((temp[1], temp[0]))

		return conns

	# black list fixed connections
	def is_not_blacklisted(self, a, b):
		# TODO: remove IOLOGIC from blacklist
		blacklist = ["_CIBTEST", "45K_", "85K_"]
		for i in blacklist:
			if i in a or i in b:
				return False
		return True

	def get_port_declarations(self):
		port_declarations = []
		for signal in self.internal_signals:
			port_declarations.append("wire {};".format(self.get_unique_name(signal)))
		return port_declarations

	def get_arcs(self):
		all_arcs = []
		# TODO: this routing seems fishy...
		if self.type == "PLC2":
			# FX_SLICE to FX by default if FX not driven
			for i in range(8):
				if not self.arc_sink_contain("F{}".format(i)):
					self.internal_signals.add("F{}_SLICE".format(i))
					self.internal_ports.add("F{}_SLICE".format(i))
					self.arcs.append(("F{}_SLICE".format(i), "F{}".format(i)))

			# MUXLSRX [0,3] defaults to zero
			for i in range(4):
				if not self.arc_sink_contain("MUXLSR{}".format(i)):
					self.internal_signals.add("MUXLSR{}_SLICE".format(i))
					self.arcs.append(("1'b0", "MUXLSR{}".format(i)))

		for connection in (self.arcs + self.fixed_conns):
			all_arcs.append("assign {} = {};".format(self.get_unique_name(connection[1]), self.get_unique_name(connection[0])))
		
		return all_arcs

	def get_instantiation(self):
		all_instantiations = []
		if self.type == "PLC2":
			# Create PLC2 tile slices
			port_declarations = []
			for i in self.internal_ports:
				port_declarations.append(".{}({})".format(i, self.get_unique_name(i)))
			port_declarations_str = ", ".join(port_declarations)

			enum_declarations = []
			for i in self.enums:
				l = i.replace(".", "_")
				r = str(self.enums[i])
				enum_declarations.append(".{}(\"{}\")".format(l, r))

			# process words
			for i in self.words:
				l = i.replace(".", "_")
				r = str(self.words[i])
				if l.endswith("INIT"):
					r = "16'b" + r
				if l.endswith("K0_INIT") or l.endswith("K1_INIT"):
					l = l.replace("K0_INIT", "LUT0_INITVAL")
					l = l.replace("K1_INIT", "LUT1_INITVAL")
				enum_declarations.append(".{}({})".format(l, r))
			enum_declarations_str = ", ".join(enum_declarations)

			all_instantiations.append("tile_PLC2 #({}) {} ({});\n".format(enum_declarations_str, self.name.replace(":", "_") + "_inst", port_declarations_str))
		elif self.type == "MIB_EBR0" or self.type == "MIB_EBR2" or self.type == "MIB_EBR4" or self.type == "MIB_EBR6":
			port_declarations = []
			for i in self.internal_ports:
				port_declarations.append(".{}({})".format(i, self.get_unique_name(i)))
			port_declarations_str = ", ".join(port_declarations)
			all_instantiations.append("PDPW16KD_wrapper2 {} ({});\n".format(self.name.replace(":", "_") + "_inst", port_declarations_str))
		else:
			# print("\nSites for {}".format(self.name))
			all_sites = self.tilegrid[self.name]["sites"]
			# for site in all_sites:
			# 	print(site["name"])
		return all_instantiations

	def get_unique_name(self, signal):
		if signal == "1'b0":
			return signal
		for tile in self.tile_map[self.row][self.col]:
			if signal in tile.internal_signals:
				return tile.name.replace(":", "_") + "_" + signal
		assert signal_is_global(signal)
		return self.get_global_unique_name(signal)

	def get_global_unique_name(self, signal):
		global_id = signal.split("_")[0]
		internal_signal_name = "_".join(signal.split("_")[1:])
		global_whitelist = ["L", "G", "R"]
		if global_id[0] in global_whitelist:
			return signal
		off_x = 0
		off_y = 0
		direction_map = {"E":(0, 1), "W":(0, -1), "N":(-1, 0), "S":(1, 0)}
		for i in range(0, len(global_id), 2):
			direction = global_id[i]
			offset = int(global_id[i + 1])
			assert direction in direction_map
			off_x += direction_map[direction][0] * offset
			off_y += direction_map[direction][1] * offset
		neighbor_x = self.row + off_x
		neighbor_y = self.col + off_y
		for neighboring_tile in self.tile_map[neighbor_x][neighbor_y]:
			if internal_signal_name in neighboring_tile.internal_signals:
				return neighboring_tile.get_unique_name(internal_signal_name)
		# TODO: look into?
		# print("Signal not found {} {} {} {} {}".format(self.name, signal, neighbor_x, neighbor_y, neighboring_tile.type))
		# Just take the first block
		neighboring_tile = self.tile_map[neighbor_x][neighbor_y][0]
		neighboring_tile.internal_signals.add(internal_signal_name)
		return self.get_global_unique_name(signal)

	def arc_sink_contain(self, signal):
		for conn in self.arcs:
			if conn[1] == signal:
				return True
		return False

	def add_arc(self, sink, source):
		if not signal_is_global(source):
			self.internal_signals.add(source)
			if "_" in source:
				self.internal_ports.add(source)
		if not signal_is_global(sink):
			self.internal_signals.add(sink)
			if "_" in sink:
				self.internal_ports.add(sink)
		self.arcs.append((source, sink))

	def add_enum(self, name, value):
		self.enums[name] = value

	def add_word(self, name, value):
		self.words[name] = value

class ECP5:
	def __init__(self, tcf):
		self.N_ROWS = 51
		self.N_COLS = 73
		tilegrid_path = "./prjtrellis-db/ECP5/LFE5U-25F/tilegrid.json"

		tilegrid = json.loads(open(tilegrid_path, "r").read())

		self.tile_dict = {}

		self.global_ports = set()

		self.tile_map = [[0]*self.N_COLS for i in range(self.N_ROWS)]
		for i in range(self.N_ROWS):
			for j in range(self.N_COLS):
				self.tile_map[i][j] = []
		for tile in tilegrid:
			new_tile = Tile(tile, self.tile_map, self.global_ports, tilegrid)
			self.tile_map[new_tile.row][new_tile.col].append(new_tile)
			self.tile_dict[new_tile.name] = new_tile

		self.parse_tcf(tcf)

		self.all_port_declarations = []
		self.all_arcs = []
		self.all_instantiations = []

		self.process_arcs() # This before port dec because there can be relative routing signals that don't have a name internally within a Tile
		self.process_port_declarations()

		self.graph = Graph(self.all_arcs)
		self.top_ports = self.graph.find_top_ports()

		self.process_instantiations()
		self.code = "`include \"tile.v\"\nmodule top (\n{}\n);\n".format(",\n".join(self.top_ports))
		self.code += "\n".join(self.all_port_declarations)
		self.code += "\n".join(self.all_arcs)
		self.code += "\n".join(self.all_instantiations)
		self.code += "endmodule"

	def parse_tcf(self, fname):
		with open(fname, "r") as f:
			data = f.read().strip()

		current_tile = None
		for i in data.split("\n"):
			if i.strip() == "":
				continue
			if i.startswith(".device"):
				self.device = i.split()[1]
			elif i.startswith(".comment"):
				self.comment = " ".join(i.split()[1:])
			elif i.startswith(".tile"):
				tile_name = i.split()[1]
				# Mismatch with db?
				tile_name = tile_name.replace("CIB_DCU", "VCIB_DCU")
				current_tile = self.tile_dict[tile_name]
			elif i.startswith("arc:"):
				arc_sink = i.split()[1]
				arc_source = i.split()[2]
				current_tile.add_arc(arc_sink, arc_source)
			elif i.startswith("word:"):
				word_name = i.split()[1]
				word_value = i.split()[2]
				current_tile.add_word(word_name, word_value)
			elif i.startswith("enum:"):
				enum_name = i.split()[1]
				enum_value = i.split()[2]
				current_tile.add_enum(enum_name, enum_value)
			elif i.startswith("unknown:"):
				print("UNK: " + i.strip())
			else:
				print("Not supported", i.strip())

	def process_port_declarations(self):
		for tile_name in self.tile_dict:
			tile = self.tile_dict[tile_name]
			self.all_port_declarations += tile.get_port_declarations()
		for port_name in self.global_ports:
			self.all_port_declarations.append("wire {};".format(port_name))

	def process_arcs(self):
		for tile_name in self.tile_dict:
			tile = self.tile_dict[tile_name]
			self.all_arcs += tile.get_arcs()

	def process_instantiations(self):
		for tile_name in self.tile_dict:
			tile = self.tile_dict[tile_name]
			self.all_instantiations += tile.get_instantiation()

	def write_code(self, fname):
		with open(fname, "w") as f:
			f.write(self.code)
		print("Finished - Code written to {}".format(fname))

os.system("ecpunpack example/counter.bit example/counter.tcf")
ecp5 = ECP5("example/counter.tcf")
ecp5.write_code("example/counter_decomp.v")
