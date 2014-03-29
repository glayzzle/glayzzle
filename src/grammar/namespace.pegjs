
namespace_statement
  = T_NAMESPACE __+ n:namespace_name __* ';' {
    return { type: 'internal.T_NAMESPACE', name: n, body: false };
  }
  / T_NAMESPACE __+ n:namespace_name __* '{' b:top_statement* '}' {
    return { type: 'internal.T_NAMESPACE', name: n, body: b };
  }
  / T_NAMESPACE __* '{' b:top_statement* '}' {
    return { type: 'internal.T_NAMESPACE', name: '\\', body: b };
  }
  / T_USE __+ u:namespace_list_alias __* ';' {
    return { type: 'internal.T_USE', ns: u };
  }

namespace_name
  = T_NS_SEPARATOR? (T_STRING T_NS_SEPARATOR)* T_STRING { return text(); }

namespace_list_alias
  = e:namespace_alias l:( __* ',' __* namespace_alias)* { return makeList(e, l); }

namespace_alias
  = n:namespace_name a:(__+ T_AS __+ T_STRING)? {
    return {
      name: n, alias: typeof(a) == 'undefined' || !a ? false: a[3]
    }
  }
