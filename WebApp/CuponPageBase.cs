using System;
using Dominio.Enums;

namespace WebApp
{
    // Clase base de las pantallas de cupones (admin y cliente).
    // Centraliza los helpers de presentación que ambas usan en el markup,
    // así dejan de estar duplicados en los dos code-behind.
    public abstract class CuponPageBase : System.Web.UI.Page
    {
        protected string GetBadgeSymbol(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.Porcentaje ? "%" : "$";
        }

        protected string GetTipoNombre(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.ReservaGratis ? "Reserva gratis" : "Descuento en reserva";
        }

        protected string GetEstadoBadgeClass(object estadoObj)
        {
            EstadoCupon estado = (EstadoCupon)estadoObj;
            switch (estado)
            {
                case EstadoCupon.Activo:   return "tag-ok";
                case EstadoCupon.Canjeado: return "tag-neutral";
                case EstadoCupon.Vencido:  return "tag-warn";
                case EstadoCupon.Agotado:  return "tag-danger";
                default:                   return "tag-neutral";
            }
        }

        protected string FormatearValor(object tipoDescuentoObj, object valorObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            if (tipo == TipoDescuento.ReservaGratis) return "GRATIS";
            if (valorObj == null || valorObj == DBNull.Value) return "-";
            decimal valor = Convert.ToDecimal(valorObj);
            return valor == 100 ? "100% OFF" : $"{valor:0}% OFF";
        }

        // El caso de reservas difiere según la pantalla:
        //   "reservas-requeridas" -> admin: la REGLA ("Requiere X reservas")
        //   "reservas-obtenidas"  -> cliente: con qué se GANÓ ("Obtenido con X reservas")
        // Los casos fecha y usos son idénticos para ambas.
        protected string FormatearMeta(string tipo, object val1, object val2 = null)
        {
            switch (tipo)
            {
                case "reservas-requeridas":
                    return "Requiere " + val1 + " reservas";
                case "reservas-obtenidas":
                    return "🎯 Obtenido con " + val1 + " reservas";
                case "fecha":
                    if (val1 == null || val1 == DBNull.Value) return "Sin vencimiento";
                    return "Válido hasta: " + Convert.ToDateTime(val1).ToString("yyyy-MM-dd");
                case "usos":
                    string limite = (val2 == null || val2 == DBNull.Value) ? "∞" : val2.ToString();
                    return "Usado: " + val1 + "/" + limite + " veces";
                default:
                    return "";
            }
        }
    }
}
