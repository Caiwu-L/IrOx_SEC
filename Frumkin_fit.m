  function Res=Frumkin_fit(x0,x,y)
%frumkin isotherm potentual=0.0256*log(theta./(1-theta))+r*theta+E0
r=x0(1);
E0=x0(2);
Res=sum(((0.0256*log(x./(1-x))+r*x+E0-y).^2));
  end







