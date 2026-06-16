using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Web;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class Calendario : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            if (u.Rol == RolUsuario.Cliente) { Response.Redirect("~/Dashboard.aspx"); return; }

            if (!IsPostBack)
            {
                ViewState["año"] = DateTime.Today.Year;
                ViewState["mes"] = DateTime.Today.Month;
                CargarCalendario();
            }
        }

        private void CargarCalendario()
        {
            int año = (int)ViewState["año"];
            int mes  = (int)ViewState["mes"];

            CultureInfo ar = new CultureInfo("es-AR");
            string nombreMes = new DateTime(año, mes, 1).ToString("MMMM yyyy", ar);
            lblMesAno.Text = char.ToUpper(nombreMes[0]) + nombreMes.Substring(1);

            List<Reserva> reservas = new NegocioReservas().ObtenerPorMes(año, mes);
            litCalendario.Text = GenerarCalendario(año, mes, reservas);
        }

        private string GenerarCalendario(int año, int mes, List<Reserva> reservas)
        {
            StringBuilder sb = new StringBuilder();
            DateTime primerDia = new DateTime(año, mes, 1);
            int diasEnMes = DateTime.DaysInMonth(año, mes);

            // DayOfWeek: Sunday=0 -> col 0 (Dom), Monday=1 -> col 1 (Lun), ..., Saturday=6 -> col 6 (Sáb)
            int inicioCol = (int)primerDia.DayOfWeek;
            int filas = (int)Math.Ceiling((inicioCol + diasEnMes) / 7.0);
            DateTime hoy = DateTime.Today;

            sb.Append("<table class='cal-tabla table table-bordered mb-0'>");
            sb.Append("<thead class='table-light'><tr>");
            foreach (string d in new[] { "Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb" })
                sb.AppendFormat("<th class='cal-th'>{0}</th>", d);
            sb.Append("</tr></thead><tbody>");

            for (int fila = 0; fila < filas; fila++)
            {
                sb.Append("<tr>");
                for (int col = 0; col < 7; col++)
                {
                    int dia = fila * 7 + col - inicioCol + 1;

                    if (dia < 1 || dia > diasEnMes)
                    {
                        sb.Append("<td class='cal-celda cal-fuera-mes'></td>");
                        continue;
                    }

                    DateTime fecha = new DateTime(año, mes, dia);
                    bool esHoy = fecha == hoy;

                    sb.AppendFormat("<td class='cal-celda{0}'>", esHoy ? " cal-dia-hoy" : "");
                    sb.AppendFormat("<span class='cal-num{0}'>{1}</span>",
                        esHoy ? " cal-num-hoy" : "", dia);

                    foreach (Reserva r in reservas.FindAll(r2 => r2.Fecha.Date == fecha))
                    {
                        string nombre = HttpUtility.HtmlEncode(r.Cliente.Nombre + " " + r.Cliente.Apellido);
                        sb.AppendFormat("<div class='cal-evento {0}'>{1} {2}</div>",
                            GetClaseEvento(r.Estado),
                            r.HoraInicio.ToString(@"H\:mm"),
                            nombre);
                    }

                    sb.Append("</td>");
                }
                sb.Append("</tr>");
            }

            sb.Append("</tbody></table>");
            return sb.ToString();
        }

        private string GetClaseEvento(EstadoReserva estado)
        {
            switch (estado)
            {
                case EstadoReserva.Nueva:        return "cal-nueva";
                case EstadoReserva.Reprogramada: return "cal-reprogramada";
                case EstadoReserva.Cancelada:    return "cal-cancelada";
                case EstadoReserva.Finalizada:   return "cal-finalizada";
                default:                          return "cal-noasistio";
            }
        }

        protected void btnAnterior_Click(object sender, EventArgs e)
        {
            DateTime dt = new DateTime((int)ViewState["año"], (int)ViewState["mes"], 1).AddMonths(-1);
            ViewState["año"] = dt.Year;
            ViewState["mes"] = dt.Month;
            CargarCalendario();
        }

        protected void btnSiguiente_Click(object sender, EventArgs e)
        {
            DateTime dt = new DateTime((int)ViewState["año"], (int)ViewState["mes"], 1).AddMonths(1);
            ViewState["año"] = dt.Year;
            ViewState["mes"] = dt.Month;
            CargarCalendario();
        }

        protected void btnHoy_Click(object sender, EventArgs e)
        {
            ViewState["año"] = DateTime.Today.Year;
            ViewState["mes"] = DateTime.Today.Month;
            CargarCalendario();
        }
    }
}
