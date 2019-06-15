/*********************************************
 * OPL 12.8.0.0 Model
 * Author: Diego
 * Creation Date: 16 ���. 2019 �. at 15:55:54
 *********************************************/
//���������
int n =...; // ����� �������
range stations =1..n;
int t =...; // ����� ���� � ����� ��������� ������������
range iterations=1..t;
range iterations_1=1..t-1; // ������ ��� �������, ����������� �� � ��������� ����
range iterations2=t+1..20; // ������ ��� ������� ��������� ������������
float Price_p[stations][stations]=...; // ������ �� �������� ��������
int Time_p[stations][stations]=...; // ����� �������� ���������
float Price_z[stations][stations]=...; // ������ �� �������� ��������
int Time_z[stations][stations]=...; // ����� �� �������� ��������
int Quantity_z[stations][stations]=...; // ������ �� �������� ��������
int Start[stations]=...; // ��������� ��������� ������� �� ��������
int NI[stations][iterations_1]=...; // ������, �������������� � ������� ������� t � ����������� ������
//���������� �������
dvar int+ x[iterations][stations][stations]; // �������� �������� �������
dvar int+ y[iterations][stations][stations]; // �������� �������� �������
dvar int+ x2[iterations2][stations][stations]; // �������� �������� �� 2-�� ��������� ������������
dvar int+ y2[iterations2][stations][stations]; // �������� �������� �� 2-�� ��������� ������������

dexpr float revenue1 = sum(t in iterations, i in stations, j in stations) Price_z[i][j]*x[t][i][j];
dexpr float cost1 = sum(t in iterations, i in stations, j in stations) Price_p[i][j]*y[t][i][j];
dexpr float revenue2 = sum(t in iterations2, i in stations, j in stations) Price_z[i][j]*x2[t][i][j];
dexpr float cost2 = sum(t in iterations2, i in stations, j in stations) Price_p[i][j]*y2[t][i][j];

dexpr float profit = revenue1-cost1+revenue2-cost2;
maximize profit;

subject to{
	// ��������� ��������� �������
	forall(i in stations)
	  start:
	  sum(j in stations, t in iterations: t == 1) (x[t][i][j]+y[t][i][j])==Start[i];
	// �������� �������� �� ������ ��������� ����� ������  
	forall(i in stations, j in stations)
	  zayvki:
	  sum(t in iterations) x[t][i][j] <=Quantity_z[i][j];
	// ���������� ���������: ����� �������, ���������� � t ������ ���� ����� ����� �������� ������� � t+1
	// �������������: ���, ��� ������� � ������ ������� t (������ 1 ����), ����� ������ �
	// ����� ������ ����� ���, ������� �� � ��������� ����
	forall (i in stations, t in iterations: t<10)
	  balans:
	  sum(tt in iterations: tt<=t)
	    (sum(ii in stations: tt+Time_z[ii][i]==t) x[tt][ii][i]
	    +sum(ii in stations: tt+Time_p[ii][i]==t) y[tt][ii][i])
	  +NI[i][t]
	  -sum(jj in stations) (x[t+1][i][jj]+y[t+1][i][jj])==0;
	// �������������� ���� ��� ����� ���� ���������� ���������� ������������
	// ��������� ��������� �������
	forall(i in stations)
	  start2:
	  sum(t in iterations: t==10) (y[t][i][i]) ==
	  sum(j in stations, t in iterations2: t == 11) (x2[t][i][j]+y2[t][i][j]);  	
	// �������� �������� �� ������ ��������� ����� ������ 
	forall(i in stations, j in stations)
	  zayvki2:
	  sum(t in iterations2) x2[t][i][j] <=Quantity_z[i][j];
	// ���������� ���������: ����� �������, ���������� � t ������ ���� ����� ����� �������� ������� � t+1
	// �������������: ���, ��� ������� � ������ ������� t (������ 1 ����), ����� ������ �
	// ����� ������ ����� ���, ������� �� � ��������� ����
	forall (i in stations, t in iterations2: t<20)
	  balans2:
	  sum(tt in iterations2: tt<=t)
	    (sum(ii in stations: tt+Time_z[ii][i]==t) x2[tt][ii][i]
	    +sum(ii in stations: tt+Time_p[ii][i]==t) y2[tt][ii][i])
	    +sum(t1 in iterations)
	      	(sum(iii in stations: t1+Time_z[iii][i]==t) x[t1][iii][i]
	      	+sum(iii in stations: t1+Time_p[iii][i]==t) y[t1][iii][i])
	      		-sum(jj in stations) (x2[t+1][i][jj]+y2[t+1][i][jj])==0;
}
	// ���������� ������ �������� � �������� ��������� � ���� Excel
tuple Tuple{
	int t;
	int i;
	int j;
	int value;
}
{Tuple} Setz = {<t,i,j,x[t][i][j]> | t in iterations, i in stations, j in stations: x[t][i][j]>0};
{Tuple} Setp = {<t,i,j,y[t][i][j]> | t in iterations, i in stations, j in stations: y[t][i][j]>0};