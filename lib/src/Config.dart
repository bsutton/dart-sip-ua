import 'Utils.dart' as Utils;
import 'Constants.dart' as JsSIP_C;
import 'Grammar.dart';
import 'URI.dart';
import 'Socket.dart' as Socket;
import 'Exceptions.dart' as Exceptions;

// Default settings.
class Settings {
  // SIP authentication.
  var authorization_user = null;
  var password = null;
  var realm = null;
  var ha1 = null;

  // SIP account.
  var display_name = null;
  var uri = null;
  var contact_uri = null;
  var user_agent = JsSIP_C.USER_AGENT;

  // SIP instance id (GRUU).
  var instance_id = null;

  // Preloaded SIP Route header field.
  var use_preloaded_route = false;

  // Session parameters.
  var session_timers = true;
  var session_timers_refresh_method = JsSIP_C.UPDATE;
  var no_answer_timeout = 60;

  // Registration parameters.
  var register = true;
  var register_expires = 600;
  var registrar_server = null;

  // Connection options.
  var sockets = null;
  var connection_recovery_max_interval = 30;
  var connection_recovery_min_interval = 2;

  /*
   * Host address.
   * Value to be set in Via sent_by and host part of Contact FQDN.
  */
  var via_host = '${Utils.createRandomToken(12)}.invalid';

  // JsSIP ID
  var jssip_id = null;

  var hostport_params = null;
}

var settings = new Settings();

// Configuration checks.
class Checks {
  var mandatory = {
    'sockets': (src, dst) {
      var sockets = src.sockets;
      /* Allow defining sockets parameter as:
       *  Socket: socket
       *  List of Socket: [socket1, socket2]
       *  List of Objects: [{socket: socket1, weight:1}, {socket: Socket2, weight:0}]
       *  List of Objects and Socket: [{socket: socket1}, socket2]
       */
      var _sockets = [];
      if (sockets != null && Socket.isSocket(sockets)) {
        _sockets.add({'socket': sockets});
      } else if (sockets is List && sockets.length > 0) {
        for (var socket in sockets) {
          if (Socket.isSocket(socket)) {
            _sockets.add(socket);
          }
        }
      } else {
        throw new Exceptions.ConfigurationError("sockets", sockets);
      }

      dst.sockets = _sockets;
    },
    'uri': (src, dst) {
      var uri = src.uri;
      if (src.uri == null && dst.uri == null) {
        throw new Exceptions.ConfigurationError("uri", null);
      }
      if (!uri.contains(new RegExp(r'^sip:', caseSensitive: false))) {
        uri = '${JsSIP_C.SIP}:${uri}';
      }
      var parsed = URI.parse(uri);
      if (parsed == null) {
        throw new Exceptions.ConfigurationError("uri", parsed);
      } else if (parsed.user == null) {
        throw new Exceptions.ConfigurationError("uri", parsed);
      } else {
        dst.uri = parsed;
      }
    }
  };
  var optional = {
    'authorization_user': (src, dst) {
      var authorization_user = src.authorization_user;
      if (authorization_user == null) return;
      if (Grammar.parse('"${authorization_user}"', 'quoted_string') == -1) {
        return;
      } else {
        dst.authorization_user = authorization_user;
      }
    },
    'user_agent': (src, dst) {
      var user_agent = src.user_agent;
      if (user_agent == null) return;
      if (user_agent is String) {
        dst.user_agent = user_agent;
      }
    },
    'connection_recovery_max_interval': (src, dst) {
      var connection_recovery_max_interval =
          src.connection_recovery_max_interval;
      if (connection_recovery_max_interval == null) return;
      if (connection_recovery_max_interval > 0) {
        dst.connection_recovery_max_interval = connection_recovery_max_interval;
      }
    },
    'connection_recovery_min_interval': (src, dst) {
      var connection_recovery_min_interval =
          src.connection_recovery_min_interval;
      if (connection_recovery_min_interval == null) return;
      if (connection_recovery_min_interval > 0) {
        dst.connection_recovery_min_interval = connection_recovery_min_interval;
      }
    },
    'contact_uri': (src, dst) {
      var contact_uri = src.contact_uri;
      if (contact_uri == null) return;
      if (contact_uri is String) {
        var uri = Grammar.parse(contact_uri, 'SIP_URI');
        if (uri != -1) {
          dst.contact_uri = uri;
        }
      }
    },
    'display_name': (src, dst) {
      var display_name = src.display_name;
      if (display_name == null) return;
      dst.display_name = display_name;
    },
    'instance_id': (src, dst) {
      var instance_id = src.instance_id;
      if (instance_id == null) return;
      if (instance_id.contains(RegExp(r'^uuid:', caseSensitive: false))) {
        instance_id = instance_id.substr(5);
      }
      if (Grammar.parse(instance_id, 'uuid') == -1) {
        return;
      } else {
        dst.instance_id = instance_id;
      }
    },
    'no_answer_timeout': (src, dst) {
      var no_answer_timeout = src.no_answer_timeout;
      if (no_answer_timeout == null) return;
      if (no_answer_timeout > 0) {
        dst.no_answer_timeout = no_answer_timeout;
      }
    },
    'session_timers': (src, dst) {
      var session_timers = src.session_timers;
      if (session_timers == null) return;
      if (session_timers is bool) {
        dst.session_timers = session_timers;
      }
    },
    'session_timers_refresh_method': (src, dst) {
      var method = src.session_timers_refresh_method;
      if (method == null) return;
      if (method is String) {
        method = method.toUpperCase();
        if (method == JsSIP_C.INVITE || method == JsSIP_C.UPDATE) {
          dst.session_timers_refresh_method = method;
        }
      }
    },
    'password': (src, dst) {
      var password = src.password;
      if (password == null) return;
      dst.password = password.toString();
    },
    'realm': (src, dst) {
      var realm = src.realm;
      if (realm == null) return;
      dst.realm = realm.toString();
    },
    'ha1': (src, dst) {
      var ha1 = src.ha1;
      if (ha1 == null) return;
      dst.ha1 = ha1.toString();
    },
    'register': (src, dst) {
      var register = src.register;
      if (register == null) return;
      if (register is bool) {
        dst.register = register;
      }
    },
    'register_expires': (src, dst) {
      var register_expires = src.register_expires;
      if (register_expires == null) return;
      if (register_expires > 0) {
        dst.register_expires = register_expires;
      }
    },
    'registrar_server': (src, dst) {
      var registrar_server = src.registrar_server;
      if (registrar_server == null) return;
      if (!registrar_server
          .contains(new RegExp(r'^sip:', caseSensitive: false))) {
        registrar_server = '${JsSIP_C.SIP}:${registrar_server}';
      }
      var parsed = URI.parse(registrar_server);
      if (parsed == null || parsed.user != null) {
        return;
      } else {
        dst.registrar_server = parsed;
      }
    },
    'use_preloaded_route': (src, dst) {
      var use_preloaded_route = src.use_preloaded_route;
      if (use_preloaded_route == null) return;
      if (use_preloaded_route is bool) {
        dst.use_preloaded_route = use_preloaded_route;
      }
    }
  };
}

final checks = new Checks();

load(dst, src) {
  try {
    // Check Mandatory parameters.
    checks.mandatory.forEach((parameter, fun) {
      //print('Check mandatory parameter => ${parameter}');
      fun(src, dst);
    });

    // Check Optional parameters.
    checks.optional.forEach((parameter, fun) {
      //print('Check optional parameter => ${parameter}');
      fun(src, dst);
    });
  } catch (e) {
    throw e;
  }
}
