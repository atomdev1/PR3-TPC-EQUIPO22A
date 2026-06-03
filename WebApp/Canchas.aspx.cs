using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;

namespace WebApp
{
    public partial class Canchas : System.Web.UI.Page
    {
        protected Repeater rptCanchas;
        protected Label lblTotal;
        protected Button btnNuevaCancha;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CargarCanchas();
            }
        }

        private void CargarCanchas()
        {
            List<Cancha> canchas = new List<Cancha>
            {
                new Cancha { IdCancha = 1, NombreFantasia = "Cancha Tenis Central", Precio = 6000, IdDeporte = (int)TipoDeporte.Tenis, CapacidadJugadores = 4, Descripcion = "Polvo de ladrillo · Iluminación", Activa = true },
                new Cancha { IdCancha = 2, NombreFantasia = "Cancha Vóley Playa", Precio = 5000, IdDeporte = (int)TipoDeporte.Voley, CapacidadJugadores = 12, Descripcion = "Arena", Activa = true },
                new Cancha { IdCancha = 3, NombreFantasia = "Cancha Pádel 1", Precio = 8000, IdDeporte = (int)TipoDeporte.Padel, CapacidadJugadores = 4, Descripcion = "Césped sintético · Techada", Activa = true },
                new Cancha { IdCancha = 4, NombreFantasia = "Cancha Fútbol 5 - A", Precio = 15000, IdDeporte = (int)TipoDeporte.Futbol, CapacidadJugadores = 10, Descripcion = "Césped sintético · Iluminación", Activa = true },
                new Cancha { IdCancha = 5, NombreFantasia = "Cancha Fútbol 5 - B", Precio = 15000, IdDeporte = (int)TipoDeporte.Futbol, CapacidadJugadores = 10, Descripcion = "Césped sintético", Activa = false },
                new Cancha { IdCancha = 6, NombreFantasia = "Cancha Básquet", Precio = 10000, IdDeporte = (int)TipoDeporte.Basquet, CapacidadJugadores = 10, Descripcion = "Cemento · Techada · Iluminación", Activa = true },
            };

            rptCanchas.DataSource = canchas;
            rptCanchas.DataBind();

            lblTotal.Text = canchas.Count + " canchas registradas";
        }

        protected void rptCanchas_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idCancha = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                Response.Redirect("EditarCancha.aspx?id=" + idCancha);
            }
            else if (e.CommandName == "Eliminar")
            {
                // HACER: llamar a la capa Negocio para "eliminar" (baja logica)
            }
        }

        protected void btnNuevaCancha_Click(object sender, EventArgs e)
        {
            Response.Redirect("NuevaCancha.aspx");
        }
    }
}
