#!/usr/bin/python

import re
import argparse
import json

import os

multiplier_offset_fix = {
    "total_training_effect" : (10, 0 ),
    "total_anaerobic_training_effect" : (10, 0),
}

class Context:
    def __init__(self):
        self.structs = {}
        self.enums = {}
        self.units = {}
        self.types = {}
        self.counts = {}
        self.fieldnum = {}

    def add_units(self,other):
        for m,u in other.iteritems():
            self.units[m] = u


    def add_field_num(self,groups):
        mesg = 'FIT_MESG_NUM_{}'.format(groups[1])
        if mesg not in self.fieldnum:
            self.fieldnum[mesg] = {}
        self.fieldnum[mesg][groups[3]] = groups[2].lower()


    def swift_field_num_for_mesg_func_name( self,mesg ):
        # remove FIT_MESG_NUM_

        nice_mesg = mesg[13:].lower()
        return 'rzfit_field_num_for_{}'.format(nice_mesg)

    def objc_field_num_for_mesg_func(self,mesg):
        if mesg in self.fieldnum:
            rv = [ 'NSString * objc_{}(FIT_UINT16 field) {{'.format( self.swift_field_num_for_mesg_func_name(mesg) ),
                   '  switch (field) {',
                   ]
            
            for (key,val) in self.fieldnum[mesg].iteritems():
                rv += [ '    case {}: return @"{}";'.format( key,val ) ]

            rv += [ '  default: return nil;',
                    '  }',
                    '}'
                    ]
            return rv
        return []

    def objc_field_num_func_decl(self):
        rv = [ 'extern NSString * objc_rzfit_field_num_to_field( FIT_MESG_NUM messageType, FIT_UINT16 field );',

               ]
        return rv

    def objc_field_num_func(self):
        mesgs = ['FIT_MESG_NUM_RECORD','FIT_MESG_NUM_LAP','FIT_MESG_NUM_SESSION','FIT_MESG_NUM_LENGTH']

        rv = []
        for mesg in mesgs:
            one = self.objc_field_num_for_mesg_func(mesg)
            rv += one

        rv += [ 'NSString * objc_rzfit_field_num_to_field( FIT_MESG_NUM messageType, FIT_UINT16 field ) {',
               '  switch (messageType) {',
               ]

        for mesg in mesgs:
            rv += [ '    case {}: return objc_{}(field);'.format( mesg,self.swift_field_num_for_mesg_func_name(mesg) ) ]
            
        rv += ['    default: return nil;',
               '   }',
               '}'

               ]
        return rv

    def json_update_map(self, existing):
        mesgs = ['FIT_MESG_NUM_RECORD','FIT_MESG_NUM_LAP','FIT_MESG_NUM_SESSION','FIT_MESG_NUM_LENGTH']
        rv = existing.copy()
        for mesg in mesgs:
            if mesg in rv:
                msgdict = rv[mesg]
            else:
                msgdict = {}

            for (key,val) in self.fieldnum[mesg].iteritems():
                if val not in msgdict:
                    msgdict[val] = val

            rv[mesg] = msgdict
        return rv

    
    def swift_field_num_for_mesg_func(self,mesg):
        if mesg in self.fieldnum:
            rv = [ 'func {}(field : FIT_UINT16) -> String? {{'.format( self.swift_field_num_for_mesg_func_name(mesg) ),
                   '  switch field {',
                   ]
            
            for (key,val) in self.fieldnum[mesg].iteritems():
                rv += [ '    case {}: return "{}"'.format( key,val ) ]

            rv += [ '  default: return nil',
                    '  }',
                    '}'
                    ]
            return rv
        return []

    def swift_field_num_func(self):
        mesgs = ['FIT_MESG_NUM_RECORD','FIT_MESG_NUM_LAP','FIT_MESG_NUM_SESSION','FIT_MESG_NUM_LENGTH']

        rv = []
        for mesg in mesgs:
            one = self.swift_field_num_for_mesg_func(mesg)
            rv += one

        rv += [ 'func rzfit_field_num_to_field(messageType : FIT_MESG_NUM, fieldNum : FIT_UINT16 ) -> String? {',
               '  switch messageType {',
               ]

        for mesg in mesgs:
            rv += [ '    case {}: return {}(field: fieldNum)'.format( mesg,self.swift_field_num_for_mesg_func_name(mesg) ) ]
            
        rv += ['    default: return nil',
               '   }',
               '}'

               ]
        return rv
        
    def swift_unit_function(self,context):
        rv = [ 'func rzfit_unit_for_field( field : String ) -> String? {',
               '  switch field {',
               ]
        for member,unit in self.units.iteritems():
            rv +=[ '  case "{}": return "{}"'.format( member,unit ) ]

        rv += [ '  default: return nil' ,
                '  }',
                '}' ]
        return rv

    def swift_unit_array_function(self,context):
        unitlist = {}
        for m,u in self.units.iteritems():
            unitlist[u] = 1
        
        rv = [ 'func rzfit_known_units( ) -> [String] {',
               '  return [',
               ]
        for unit,ignore in unitlist.iteritems():
            rv +=[ '  "{}",'.format( unit ) ]

        rv += [ '  ]',
                '}' ]
        return rv


class StructElem :
    def __init__(self,groups):
        self.ctype = groups[0]
        self.member = groups[1]
        self.array = groups[2][1:-1]
        self.unit = None
        self.multiplier = None
        self.offset = None

        if groups[3]:
            p = re.compile( ' // ([0-9]+) \\* ([^ ]+) \\+ ([0-9]+)' )
            m = p.match(groups[3])
            if m:
                self.unit = m.group(2)
                self.multiplier = m.group(1)
                self.offset = m.group(3)

        if self.member in multiplier_offset_fix:
            fix = multiplier_offset_fix[self.member]
            if str(fix[0]) != str(self.multiplier):
                print( 'Fixing {} with mult={} offset={}'.format( self.member, fix[0],  fix[1]) )
            self.multiplier = fix[0]
            self.offset = fix[1]


    def formula(self):
        if self.unit:
            return '({}x+{}) in [{}]'.format( self.multiplier, self.offset, self.unit )
        else:
            return ''
                
    def __repr__(self):
        if self.array:
            return '{} {}[{}] {}'.format( self.ctype, self.member, self.array, self.formula() )
        else:
            return '{} {} {}'.format( self.ctype, self.member, self.formula() )

    def swift_unit_case_statement(self,prefix=''):
        if self.unit:
            return [ prefix + 'case "{}": return "{}"'.format( self.member,self.unit ) ]
        else:
            return None

    def is_enum(self,context):
        if self.is_array():
            return False
        
        rv = False
        if self.ctype in context.types and not self.array:
            type = context.types[self.ctype]
            rv = type.is_enum()

        return rv

    def is_value(self,context):
        if self.is_array():
            if self.array in context.counts and context.counts[self.array] == 1:
                return True
            return False
        
        return not self.is_enum(context)

    def is_array(self):
        return len(self.array) > 0

    def is_string(self):
        return self.is_array() and self.ctype == 'FIT_STRING'
    
    def swift_convert_value_statement(self,context,prefix=''):
        lines = []

        member = self.member
        #if self.array in context.counts and context.counts[self.array] == 1:
        #    member = '{}[0]'.format(self.member)
        defs = { 'member': member, 'name': self.member, 'invalid': self.ctype + '_INVALID', 'multiplier':self.multiplier, 'offset':self.offset }
        if self.is_value(context):
            formula = 'Double(x.{member})'.format( **defs )
            if self.offset and float(self.offset) != 0.0:
                formula += '-Double({offset})'.format(**defs)
            if self.multiplier and float(self.multiplier) != 1.0:
                formula = '({})/Double({multiplier})'.format(formula, **defs)
            lines = [ prefix + 'if x.{member} != {invalid}  {{'.format( **defs ),
                      prefix + '  let val : Double = {}'.format( formula ),
                      prefix + '  rv[ "{name}" ] = val'.format(**defs),
                      prefix + '}'
                      ]
            
        return lines

    def swift_convert_enum_statement(self,context,prefix=''):
        lines = []
        defs = { 'member': self.member, 'invalid': self.ctype + '_INVALID', 'multiplier':self.multiplier, 'offset':self.offset }
        if self.is_enum(context):
            type = context.types[self.ctype]
            defs['function'] = type.swift_switch_function_name()
            lines = [ prefix + 'if( x.{member} != {invalid} ) {{'.format( **defs ),
                      prefix + '  rv[ "{member}" ] = {function}(input: x.{member})'.format( **defs),
                      prefix + '}'
            ]

        if self.is_string():
            lines = [ prefix + 'rv[ "{member}" ] = withUnsafeBytes(of: &x.{member}) {{ (rawPtr) -> String in'.format(**defs),
                      prefix + '  let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)',
                      prefix + '  return String(cString: ptr)',
                      prefix + '}'
            ]


            
        return lines

                                                      
class EnumElem :
    def __init__(self,groups):
        self.key = groups[0]
        
class TypeDefElem :
    def __init__(self,type_name,groups):
        self.key = groups[0]
        self.desc = groups[1].lower()
        self.num = groups[2]
        self.type_name = type_name


    def is_mask(self):
        return self.num.startswith('0x')
    
    def swift_case_statement(self,prefix ='' ):
        return '{}case {}: return "{}";'.format(prefix, self.key, self.desc)

    def swift_case_string_to_mesg_statement(self,context,prefix=''):
        rv = None
        rv = [ prefix + 'case "{}": rv = {};'.format( self.desc, self.key )]
        return rv
               
    def swift_case_mesg_statement(self,context,prefix = '' ):
        #FIT_MESG_NUM_EXD_DATA_FIELD_CONFIGURATION
        structname = self.key.replace('MESG_NUM_','') + '_MESG'

        rv = None
        if structname in context.structs:
            ex = context.structs[structname]
            rv = [ prefix + 'case {}:'.format( self.key ),
                   prefix + '  uptr.withMemoryRebound(to: {}.self, capacity: 1) {{'.format( structname ),
                   prefix + '    rv = RZFitMessage( mesg_num:    {},'.format( self.key),
                   prefix + '                       mesg_values: {}(ptr: $0),'.format( ex.swift_value_dict_function_name()),
                   prefix + '                       mesg_enums:  {}(ptr: $0))'.format(  ex.swift_enum_dict_function_name()),
                   prefix + '  }'

            ]

        return rv

    
class Struct :
    def __init__(self, groups):
        self.elements = []
        self.units = {}
    
    def add_element(self,groups):
        elem = StructElem(groups)
        self.elements += [ elem ]
        if elem.unit:
            self.units[elem.member] = elem.unit

    def close(self,groups):
        self.struct_name = groups[0]

    def name(self):
        return self.struct_name

    def swift_value_dict_function_name(self):
        return 'rz{}_value_dict'.format( self.struct_name.lower() )
    def swift_enum_dict_function_name(self):
        return 'rz{}_enum_dict'.format( self.struct_name.lower() )
    def swift_unit_function_name(self):
        return 'rzfit_unit_for_field'

    
    def swift_dict_function(self,context):
        rv = [ 'func {}( ptr : UnsafePointer<{}>) -> [String:Double] {{'.format( self.swift_value_dict_function_name(), self.struct_name ),
               ]
        elems = []
        
        for elem in self.elements:
            elems += elem.swift_convert_value_statement(context, '  ')

        if elems:
            rv += [ '  var rv : [String:Double] = [:]',
                    '  let x : {} = ptr.pointee'.format(self.struct_name)
                    ]
            rv += elems
            rv += [ '  return rv',
                    '}' ]
        else:
            rv += [ '  return [:]',
                    '}' ]
            
        
        rv += [ 'func {}( ptr : UnsafePointer<{}>) -> [String:String] {{'.format(self.swift_enum_dict_function_name(), self.struct_name ) ]
        elems = []
        hasString = False
        for elem in self.elements:
            if elem.is_string():
                hasString = True
            elems += elem.swift_convert_enum_statement(context, '  ')
        if elems:
            rv += [ '  var rv : [String:String] = [:]',
                    '  {} x : {} = ptr.pointee'.format('var' if hasString else 'let', self.struct_name)
               ]
            rv += elems
            rv += [ '  return rv',
                    '}' ]
        else:
            rv += [ '  return [:]',
                    '}'
                    ]

        return( '\n'.join(rv) )
    
class Enum :
    def __init__(self,groups):
        self.elements = []

    def add_element(self,groups):
        self.elements += [ EnumElem( groups ) ]
        
    def close(self,groups):
        self.enum_name = groups[0]

    def name(self):
        return self.enum_name
        
class TypeDef :
    def __init__(self,groups):
        self.ctype = groups[0]
        self.fit_type_name = groups[1]
        self.type_name = self.fit_type_name[4:] # remove FIT_ prefix
        self.elements = []

        self.p_define = re.compile( '#define ({}_([A-Z0-9_]+)) +..{}.([0-9xA-F]+)'.format( self.fit_type_name, self.fit_type_name ))
        self.p_count = re.compile( '#define {}_COUNT'.format( self.fit_type_name ))

    def is_enum(self):
        return len(self.elements) > 0 
        
    def add_element(self,groups):
        elem = TypeDefElem(self.type_name,groups)
        if not elem.is_mask():
            self.elements += [ elem ]

    def swift_switch_function_name(self):
        return 'rz{}_string'.format( self.fit_type_name.lower() )
        
    def swift_switch_function(self):
        if self.elements:
            rv = [ 'func {}(input : {}) -> String? '.format( self.swift_switch_function_name(), self.ctype ),
                   '{',
                   '  switch  input {' ]
            rv += [x.swift_case_statement( '    ') for x in self.elements]
            rv += ['    default: return nil',
                   '  }',
                   '}']
        else:
            rv = []
        return '\n'.join(rv)

    def name(self):
        return self.fit_type_name

    def swift_string_to_mesg(self,context):
        rv = ['public func rzfit_string_to_mesg(mesg : String) -> FIT_MESG_NUM? {',
              '  var rv : FIT_MESG_NUM? = nil',
              '  switch mesg {'
              ]
        for x in self.elements:
            one = x.swift_case_string_to_mesg_statement(context,'  ')
            if one:
                rv += one

        rv += ['  default:',
               '    rv = nil',
               '  }',
               '  return rv',
               '}',

               ]

        return '\n'.join(rv)

    
    def swift_mesg_switch(self,context):
        rv = [
            'func rzfit_build_mesg(num : FIT_MESG_NUM, uptr : UnsafePointer<UInt8>) -> RZFitMessage?{',
            '    var rv : RZFitMessage? = nil',
            '    switch num {',
            ]

        for x in self.elements:
            one = x.swift_case_mesg_statement(context,'  ')
            if one:
                rv += one

        rv += [
            '    default:',
            '       rv = RZFitMessage( mesg_num: num, mesg_values: [:], mesg_enums: [:])',
            '    }',
            '    return rv',
            '}'
            ]

        return '\n'.join(rv) 
        
    
class Convert :

    def __init__(self,args):
        self.args = args
        self.context = Context()

    def generate_json_file(self):
        
        if os.path.exists( self.args.mapfile ):
            mf = open( self.args.mapfile, 'r' )
            try:
                existing = json.load( mf )
                for message in messages:
                    if message not in messages:
                        existing[message] = {}
            except:
                existing = {}
        else:
            existing = {}

        newmap = self.context.json_update_map( existing );
        with open( self.args.mapfile, 'w' ) as of:
            json.dump( newmap, of, indent = 2, sort_keys = True )
            
        
    def generate_output_file(self):
        of = open( self.args.outputfile, 'w')
        objcf = self.args.outputfile.replace(".swift",".m")
        objch = self.args.outputfile.replace(".swift",".h")
        hf = os.path.basename( objch )
        oof = open( objcf, 'w')
        ooh = open( objch, 'w')
        
        print( 'Wrote {}'.format( args.outputfile ) )
        print( 'Wrote {}'.format( objcf ) )
        print( 'Wrote {}'.format( objch ) )
        
        of.write( '\n'.join( [
            '// This file is auto generated, Do not edit',
            'import RZFitFileTypes',
            '\n'
            ] ) )
        oof.write( '\n'.join( [
            '// This file is auto generated, Do not edit\n',
            '#include "{}"'.format( hf ),
            '\n'
        ] ) )
        ooh.write( '\n'.join( [
            '// This file is auto generated, Do not edit\n',
            '@import Foundation;',
            '#include "fit_config.h"',
            '#include "fit_example.h"',
            '#include "fit_convert.h"',
            '\n'
        ] ))

        if True:
            for typename,typedef in self.context.types.iteritems():
                of.write( typedef.swift_switch_function() )
                of.write( '\n' )
            
        if True:
            for typename,structdef in self.context.structs.iteritems():
                of.write( structdef.swift_dict_function(self.context) )
                of.write( '\n' )

        if True and 'FIT_MESG_NUM' in self.context.types:
            mesgs = self.context.types['FIT_MESG_NUM']
            of.write( mesgs.swift_mesg_switch(self.context) )
            of.write( '\n' )
            of.write(  mesgs.swift_string_to_mesg(self.context ) )
            of.write( '\n' )

        if True:
            of.write( '\n'.join( self.context.swift_unit_function(self.context) ) )
            of.write( '\n' )


        if True:
            of.write( '\n'.join( self.context.swift_unit_array_function(self.context) ) )
            of.write( '\n')

            of.write( '\n'.join( self.context.swift_field_num_func() ) )
            of.write( '\n')

        if True:
            oof.write( '\n'.join( self.context.objc_field_num_func() ) )
            oof.write( '\n')

            ooh.write( '\n'.join( self.context.objc_field_num_func_decl() ) )
            ooh.write( '\n' )
            

            
    def parse_input_file(self):
        fp = open( self.args.inputfile, 'r')
        print( 'Parsing {}'.format( self.args.inputfile ) )
        
        p_typedef = re.compile( 'typedef (FIT_[0-9A-Z_]+) ([0-9A-Z_]+)' )
        #p_typedef = re.compile( 'typedef (FIT_ENUM) ([0-9A-Z_]+)' )
        p_typedef_enum = re.compile( 'typedef enum' )
        p_typedef_struct = re.compile( 'typedef struct' )
        p_typedef_end = re.compile( '^} ([A-Z0-9_]+);' )
        p_typedef_def = re.compile( ' +([A-Z0-9_]+)[, ]' )
        p_define_count = re.compile( '#define (FIT_[A-Za-z0-9_]+_COUNT) +([0-9]+)' )
        p_field_num = re.compile( ' +(FIT_([A-Z0-9_]+)_FIELD_NUM_([A-Za-z0-9_]+)) = ([0-9]+),' )
        p_def_field_num = re.compile( '#define (FIT_([A-Z0-9_]+)_FIELD_NUM_([A-Za-z0-9_]+)) \(\(FIT_[A-Z0-9_]+_FIELD_NUM\)([0-9]+)')
        p_elem = re.compile( ' +(FIT_[A-Z0-9_]+) ([a-z_0-9]+)(|\\[[A-Z0-9_]+\\]);( // [0-9]+ * [^+]+ \\+ [0-9]+)?' )
        
        in_typedef = None
        in_typedef_enum = None
        in_typedef_struct = None
        conv_init = None

        typedef_defs = None
        
        for line in fp:
            if line.startswith( 'typedef' ):
                m = p_typedef.match( line )
                if m:
                    in_typedef = TypeDef(m.groups())
                    
                m = p_typedef_enum.match(line)
                if m:
                    in_typedef_enum = Enum(m.groups())

                m = p_typedef_struct.match(line)
                if m:
                    in_typedef_struct = Struct(m.groups())

            if line.startswith( '#define' ):
                m = p_define_count.match( line )
                if m:
                    self.context.counts[m.group(1)] = int(m.group(2))

                m = p_def_field_num.match( line )
                if m:
                    self.context.add_field_num( m.groups() )

            if line.startswith( '   FIT_' ):

                m = p_field_num.match( line )

                if m:
                    self.context.add_field_num(m.groups())
                                  
            if in_typedef_enum:
                m = p_typedef_def.match( line )
                if m:
                    in_typedef_enum.add_element(m.groups())

                m = p_typedef_end.match( line )
                if m:
                    in_typedef_enum.close(m.groups())
                    self.context.enums[ in_typedef_enum.name() ] = in_typedef_enum
                    in_typedef_enum = None
                    
            if in_typedef_struct:
                m = p_elem.match(line )
                if m:
                    in_typedef_struct.add_element(m.groups())

                m = p_typedef_end.match(line)
                if m:
                    in_typedef_struct.close(m.groups())
                    self.context.add_units( in_typedef_struct.units )
                    self.context.structs[in_typedef_struct.name()] = in_typedef_struct
                    in_typedef_struct = None
                    
            if in_typedef:
                m = in_typedef.p_define.match( line )
                    
                if m:
                    in_typedef.add_element(m.groups())
                    
                m = in_typedef.p_count.match( line )
                if m:
                    self.context.types[in_typedef.name()] = in_typedef
                    in_typedef = None



    def run(self):
        self.parse_input_file()
        self.generate_output_file()
        self.generate_json_file()

                   
if __name__ == "__main__":
    parser = argparse.ArgumentParser( description='Auto Generate swift file' )
    parser.add_argument( '-o', '--outputfile', default = 'src/rzfit_convert_auto.swift' )
    parser.add_argument( '-i', '--inputfile', default = 'sdk/fit_example.h' )
    parser.add_argument( '-m', '--mapfile', default = 'map.json' )
    args = parser.parse_args()
    conv = Convert( args )
    
    conv.run()
