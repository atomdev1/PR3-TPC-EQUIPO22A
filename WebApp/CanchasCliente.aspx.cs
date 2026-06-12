using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class CanchasCliente : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // HACER: control de acceso por rol — pendiente cambio de roles (guard centralizado futuro)
            if (!IsPostBack)
                CargarCanchas();
        }

        private void CargarCanchas()
        {
            List<Cancha> canchas = new NegocioCanchas().ObtenerCanchasActivasConDisponibilidad();
            rptCanchas.DataSource = canchas;
            rptCanchas.DataBind();
            pnlVacio.Visible = canchas.Count == 0;
            lblTotal.Text = canchas.Count + " canchas disponibles";
        }

        // Helpers reutilizados de Canchas.aspx.cs

        protected string GetDeporteEmoji(object nombreObj)
        {
            string nombre = (nombreObj ?? "").ToString().ToLower();
            if (nombre.Contains("fútbol") || nombre.Contains("futbol")) return "⚽";
            if (nombre.Contains("tenis")) return "🎾";
            if (nombre.Contains("básquet") || nombre.Contains("basquet")) return "🏀";
            if (nombre.Contains("pádel") || nombre.Contains("padel")) return "🏓";
            if (nombre.Contains("vóley") || nombre.Contains("voley")) return "🏐";
            return "🏟️";
        }

        protected string GetDeporteAccent(object nombreObj)
        {
            string nombre = (nombreObj ?? "").ToString().ToLower();
            if (nombre.Contains("fútbol") || nombre.Contains("futbol")) return "#2d6a4f";
            if (nombre.Contains("tenis")) return "#b5870a";
            if (nombre.Contains("básquet") || nombre.Contains("basquet")) return "#9b4d96";
            if (nombre.Contains("pádel") || nombre.Contains("padel")) return "#1a6fa8";
            if (nombre.Contains("vóley") || nombre.Contains("voley")) return "#c0392b";
            return "#4a5568";
        }

        protected string FormatearPrecio(object precioObj)
        {
            return "$" + precioObj + " /hora";
        }

        // Helpers nuevos

        protected string NombreDia(object diaObj)
        {
            if (diaObj == null) return "";
            switch ((DiaSemana)diaObj)
            {
                case DiaSemana.Lunes:     return "Lunes";
                case DiaSemana.Martes:    return "Martes";
                case DiaSemana.Miercoles: return "Miércoles";
                case DiaSemana.Jueves:    return "Jueves";
                case DiaSemana.Viernes:   return "Viernes";
                case DiaSemana.Sabado:    return "Sábado";
                case DiaSemana.Domingo:   return "Domingo";
                default:                  return diaObj.ToString();
            }
        }

        protected string FormatearFranja(object aperturaObj, object cierreObj)
        {
            TimeSpan apertura = (TimeSpan)aperturaObj;
            TimeSpan cierre   = (TimeSpan)cierreObj;
            return apertura.ToString(@"hh\:mm") + " - " + cierre.ToString(@"hh\:mm");
        }
    }
}
